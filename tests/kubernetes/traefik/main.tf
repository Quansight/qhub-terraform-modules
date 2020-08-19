resource "kubernetes_service" "main" {
  metadata = {
    name = var.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "traefik"
    }

    port {
      name        = "web"
      target_port = 8000
      port        = 8000
      node_port   = 9001
    }

    port {
      name        = "tcp"
      target_port = 8786
      port        = 8786
      node_port   = 9002
    }

    port {
      name        = "traefik"
      target_port = 9000
      port        = 9000
    }

    type = "LoadBalancer"
  }
}


##### convert https://github.com/dask/dask-gateway/blob/master/resources/helm/dask-gateway/templates/traefik/deployment.yaml
resource "kubernetes_deployment" "main" {
  metadata {
    name = var.name
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "traefik"
      }
    }

    template {
      metadata {
        labels = {
          app = "traefik"
        }
      }

      spec {
        volume {
          name = "configmap"
          config_map = {
            name = kubernetes_config_map.main.metadata.0.name
          }
        }

        container {
          image = "${var.gateway-image.image}:${var.gateway-image.tag}"
          name  = var.name

          command = [
            "dask-gateway-server",
            "--config",
            "/etc/dask-gateway/dask_gateway_config.py"
          ]

          volume_mount {
            name = "configmap"
            mount_path = "/etc/dask-gateway/"
          }

          env {
            name  = "JUPYTERHUB_API_TOKEN"
            value = random_password.jupyterhub_api_token
          }

          port {
            name = "api"
            container_port = 8000
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = "api"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 2
            period_seconds        = 10
            failure_threshold     = 6
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = "api"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 2
            period_seconds        = 10
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

##### convert https://github.com/dask/dask-gateway/blob/master/resources/helm/dask-gateway/templates/traefik/dashboard.yaml
# apiVersion: traefik.containo.us/v1alpha1
# kind: IngressRoute
# metadata:
#   name: {{ include "dask-gateway.fullname" . | printf "traefik-dashboard-%s" | trunc 63 | trimSuffix "-" }}
#   labels:
#     {{- include "dask-gateway.labels" . | nindent 4 }}
# spec:
#   entryPoints:
#     - traefik
#   routes:
#   - match: PathPrefix(`/dashboard`) || PathPrefix(`/api`)
#     kind: Rule
#     services:
#     - name: api@internal
#       kind: TraefikService
