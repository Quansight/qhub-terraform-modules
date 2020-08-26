resource "random_password" "proxy_secret_token" {
  length  = 32
  special = false
}


# requires hex password
resource "random_password" "hub_secret_cookie" {
  length  = 32
}


resource "random_password" "api_token" {
  count = length(var.services)
  length = 32
}


resource "kubernetes_config_map" "hub" {
  metadata {
    name = "${var.name}-jupyterhub-hub"
    namespace = var.namespace
  }

  data = {
    "jupyterhub_config.py" = templatefile("${path.module}/templates/jupyterhub_config.py", {
      proxy_public = {
        host = kubernetes_service.proxy_public.metadata.0.name
        port = 80
      }
      proxy_api = {
        host = kubernetes_service.proxy_api.metadata.0.name
        port = 8001
      }
      singleuser = var.singleuser
      hub = {
        host = kubernetes_service.hub.metadata.0.name
        port = 8081
      }
    })
  }
}


resource "kubernetes_secret" "hub" {
  metadata {
    name = "${var.name}-jupyterhub-hub"
    namespace = var.namespace
  }

  data = {
    "proxy.token" = random_password.proxy_secret_token.result
    # must be hex value
    "hub.cookie-secret" = sha256(random_password.hub_secret_cookie.result)
    "api-tokens" = jsonencode(zipmap(
      var.services,
      [for instance in random_password.api_token: instance.result]
    ))
  }
}


resource "kubernetes_persistent_volume_claim" "hub" {
  metadata {
    name      = "${var.name}-jupyterhub-hub"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}


resource "kubernetes_service" "hub" {
  metadata {
    name = "${var.name}-jupyterhub-hub"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "jupyterhub-hub"
    }

    port {
      target_port = "http"
      port        = 8081
    }
  }
}

resource "kubernetes_deployment" "hub" {
  metadata {
    name      = "${var.name}-jupyterhub-hub"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "jupyterhub-hub"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "jupyterhub-hub"
          "hub.jupyter.org/network-access-proxy-api" = "true"
          "hub.jupyter.org/network-access-proxy-http" = "true"
          "hub.jupyter.org/network-access-singleuser" = "true"
        }

        annotations = {
          # This lets us autorestart when the secret changes!
          "checksum/config-map" = sha256(jsonencode(kubernetes_config_map.hub.data))
          "checksum/secret" = sha256(jsonencode(kubernetes_secret.hub.data))
        }
      }

      spec {
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.hub.metadata.0.name
          }
        }

        volume {
          name = "secret"
          config_map {
            name = kubernetes_secret.hub.metadata.0.name
          }
        }

        volume {
          name = "hub-db-dir"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.hub.metadata.0.name
          }
        }

        service_account_name = kubernetes_service_account.hub.metadata.0.name
        automount_service_account_token = true

        container {
          name  = "hub"
          image = "${var.hub-image.image}:${var.hub-image.tag}"

          command = [
            "jupyterhub",
            "--config",
            "/etc/jupyterhub/jupyterhub_config.py",
            "--upgrade-db", # auto upgrade db
          ]

          volume_mount {
            name       = "config"
            mount_path = "/etc/jupyterhub/jupyterhub_config.py"
            sub_path = "jupyterhub_config.py"
          }

          volume_mount {
            mount_path = "/etc/jupyterhub/secret/"
            name       = "secret"
          }

          volume_mount {
            mount_path = "/srv/jupyterhub"
            name       = "hub-db-dir"
          }

          env {
            name = "PYTHONUNBUFFERED"
            value = "1"
          }

          env {
            name = "JPY_COOKIE_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.hub.metadata.0.name
                key = "hub.cookie-secret"
              }
            }
          }

          env {
            name = "CONFIGPROXY_AUTH_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.hub.metadata.0.name
                key = "proxy.token"
              }
            }
          }

          env {
            name = "JUPYTERHUB_API_SERVICE_TOKENS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.hub.metadata.0.name
                key = "api-tokens"
              }
            }
          }

          port {
            name = "http"
            container_port = 8081
          }

          # TODO: consider baseUrl
          liveness_probe {
            http_get {
              path = "/hub/health"
              port = "http"
            }

            initial_delay_seconds = 60
            period_seconds        = 10
          }

          # TODO: consider baseUrl
          readiness_probe {
            http_get {
              path = "/hub/health"
              port = "http"
            }

            initial_delay_seconds = 0
            period_seconds        = 2
          }
        }
      }
    }
  }
}
