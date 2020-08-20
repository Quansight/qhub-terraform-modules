resource "kubernetes_service" "main" {
  metadata {
    name = "${var.name}-traefik"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "traefik"
    }

    port {
      name        = "web"
      target_port = 8000
      port        = 8000
    }

    port {
      name        = "tcp"
      target_port = 8786
      port        = 8786
    }

    port {
      name        = "traefik"
      target_port = 9000
      port        = 9000
    }

    type = "NodePort"
  }
}


resource "kubernetes_deployment" "main" {
  metadata {
    name = "${var.name}-traefik"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "traefik"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "traefik"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.main.metadata.0.name

        termination_grace_period_seconds = 60

        container {
          image = "${var.traefik-image.image}:${var.traefik-image.tag}"
          name  = var.name

          security_context {
            run_as_user = 1000
            run_as_group = 1000
          }

          args = [
            "--global.checknewversion=False",
            "--global.sendanonymoususage=False",
            "--ping=true",
            "--providers.kubernetescrd",
            # "--providers.kubernetescrd.labelselector=gateway.dask.org/instance=${ include "dask-gateway.fullname"}",
            "--providers.kubernetescrd.throttleduration=2",
            "--log.level=${var.loglevel}",
            "--entryPoints.traefik.address=:9000",
            "--entryPoints.web.address=:8000",
            # {{- if ne (toString .Values.traefik.service.ports.tcp.port) "web" }}
            "--entryPoints.tcp.address=:8786",
            # dashboard
            "--api.dashboard=true",
            "--api.insecure=true"
          ]

          port {
            name = "traefik"
            container_port = 9000
          }

          port {
            name = "web"
            container_port = 8000
          }

          port {
            name = "tcp"
            container_port = 8786
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = 9000
            }

            initial_delay_seconds = 10
            timeout_seconds       = 2
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "ping"
              port = 9000
            }

            initial_delay_seconds = 10
            timeout_seconds       = 2
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 1
          }
        }
      }
    }
  }
}

# # for now requires that crd be applied successfully first
# resource "kubernetes_manifest" "ingress" {
#   provider = kubernetes-alpha

#   manifest = {
#     apiVersion = "traefik.containo.us/v1alpha1"
#     kind = "IngressRoute"
#     metadata = {
#       name = "${var.name}-dashboard"
#       namespace = var.namespace
#     }
#     spec = {
#       entryPoints = ["traefik"]
#       routes = [
#         {
#           match = "PathPrefix(`/dashboard`) || PathPrefix(`/api`)"
#           kind = "Rule"
#           services = [
#             {
#               name = "api@internal"
#               kind = "TraefikService"
#             }
#           ]
#         }
#       ]
#     }
#   }

#   depends_on = [
#     kubernetes_manifest.ingress_route
#   ]
# }
