resource "kubernetes_service" "proxy" {
  metadata {
    name = "${var.name}-jupyterhub-proxy"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "jupyterhub-proxy"
    }

    port {
      name        = "https"
      port        = 443
    }

    port {
      name        = "http"
      port        = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "proxy" {
  metadata {
    name = "${var.name}-jupyterhub-proxy"
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
          "app.kubernetes.io/component" = "jupyterhub-proxy"
          "hub.jupyter.org/network-access-hub" = "true"
          "hub.jupyter.org/network-access-singleuser" = "true"
        }
      }

      spec {
        termination_grace_period_seconds = 60

        container {
          image = "${var.proxy-image.image}:${var.proxy-image.tag}"
          name  = "${var.name}-jupyterhub-chp"

          command = [
            "configurable-http-proxy",
            "--ip=::",
            "--api-ip=::",
            "--api-port=8001",
            "--default-target=http://$(HUB_SERVICE_HOST):$(HUB_SERVICE_PORT)",
            "--error-target=http://$(HUB_SERVICE_HOST):$(HUB_SERVICE_PORT)/hub/error",
            "--port=8000",
            # "--log-level=debug"
          ]

          env {
            name  = "CONFIGPROXY_AUTH_TOKEN"
            value_from {
              secret_key_ref {
                name = "hub-secret"
                key = "proxy.token"
              }
            }
          }

          port {
            name = "http"
            container_port = 8000
          }

          port {
            name = "api"
            container_port = 8081
          }

          liveness_probe {
            http_get {
              path = "/_chp_healthz"
              port = "http"
            }

            initial_delay_seconds = 60
            period_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/_chp_healthz"
              port = "http"
            }

            initial_delay_seconds = 0
            period_seconds = 2
          }
        }
      }
    }
  }
}
