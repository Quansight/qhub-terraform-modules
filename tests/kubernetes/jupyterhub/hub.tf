resource "kubernetes_config_map" "main" {
  metadata {
    name = "${var.name}-jupyterhub"
    namespace = var.namespace
  }

  data = {
    "jupyterhub_config.py" = templatefile("${path.module}/jupyterhub_config.py", {

    })
  }
}


resource "kubernetes_persistent_volume_claim" "main" {
  metadata {
    name      = "${var.name}-jupyterhub"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.hub_storage
      }
    }
  }
}


resource "kubernetes_service" "hub" {
  metadata {
    name = "${var.name}-jupyterhub"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "jupyterhub"
    }

    port {
      name        = "http"
      target_port = 8081
      port        = 8081
    }
  }
}

resource "kubernetes_deployment" "main" {
  metadata {
    name      = "${var.name}-jupyterhub"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "jupyterhub"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "jupyterhub"
          "hub.jupyter.org/network-access-proxy-api" = "true"
          "hub.jupyter.org/network-access-proxy-http" = "true"
          "hub.jupyter.org/network-access-singleuser" = "true"
        }
      }

      spec {
        volume {
          name = "config"
          config_map = {
            name = kubernetes_config_map.main.metadata.0.name
          }
        }

        volume {
          name = "secret"
          config_map {
            name = kubernetes_secret.main.metadata.0.name
          }
        }

        volume {
          name = "hub-db-dir"
          persistent_volumne_claim = {
            claim_name = kubernetes_persistent_volume_claim.main.metadata.0.name
          }
        }

        service_account_name = kubernetes_service_account.main.metadata.0.name

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
            value_from = {
              secret_key_ref = {
                name = "hub-secret"
                key = "hub.cookie-secret"
              }
            }
          }

          # continue at POD_NAMESPACE
        }
      }
    }
  }
}
