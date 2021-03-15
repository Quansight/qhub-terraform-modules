resource "kubernetes_service" "proxy_api" {
  metadata {
    name      = "${var.name}-jupyterhub-proxy-api"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "jupyterhub-proxy"
    }

    port {
      port        = 8001
      target_port = "api"
    }
  }
}


resource "kubernetes_service" "proxy_public" {
  metadata {
    name      = "${var.name}-jupyterhub-proxy-public"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "jupyterhub-proxy"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "proxy" {
  metadata {
    name      = "${var.name}-jupyterhub-proxy"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "jupyterhub-proxy"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component"               = "jupyterhub-proxy"
          "hub.jupyter.org/network-access-hub"        = "true"
          "hub.jupyter.org/network-access-singleuser" = "true"
        }

        annotations = {
          # This lets us autorestart when the secret changes!
          "checksum/config-map" = sha256(jsonencode(kubernetes_config_map.hub.data))
          "checksum/secret"     = sha256(jsonencode(kubernetes_secret.hub.data))
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = var.proxy-node-group.key
                  operator = "In"
                  values   = [var.proxy-node-group.value]
                }
              }
            }
          }
        }

        termination_grace_period_seconds = 60

        container {
          image = "${var.proxy-image.image}:${var.proxy-image.tag}"
          name  = "${var.name}-jupyterhub-chp"

          command = [
            "configurable-http-proxy",
            "--ip=::",
            "--api-ip=::",
            "--api-port=8001",
            "--default-target=http://${kubernetes_service.hub.metadata.0.name}:8081",
            "--error-target=http://${kubernetes_service.hub.metadata.0.name}:8081/hub/error",
            "--port=8000",
            # "--log-level=debug"
          ]

          env {
            name = "CONFIGPROXY_AUTH_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.hub.metadata.0.name
                key  = "proxy.token"
              }
            }
          }

          port {
            name           = "http"
            container_port = 8000
          }

          port {
            name           = "api"
            container_port = 8001
          }

          liveness_probe {
            http_get {
              path = "/_chp_healthz"
              port = "http"
            }

            initial_delay_seconds = 60
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/_chp_healthz"
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
