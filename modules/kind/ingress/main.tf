resource "kubernetes_service_account" "main" {
  metadata {
    name      = "${var.name}-traefik"
    namespace = var.namespace
  }
}


resource "kubernetes_cluster_role" "main" {
  metadata {
    name = "${var.name}-traefik"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses", "ingressclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
}


resource "kubernetes_cluster_role_binding" "main" {
  metadata {
    name = "${var.name}-traefik"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.main.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.main.metadata.0.name
    namespace = var.namespace
  }
}


resource "kubernetes_service" "main" {
  wait_for_load_balancer = true

  metadata {
    name      = "${var.name}-traefik"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "traefik"
    }

    port {
      name     = "http"
      protocol = "TCP"
      port     = 80
    }

    port {
      name     = "https"
      protocol = "TCP"
      port     = 443
    }

    type = "LoadBalancer"
  }
}


resource "kubernetes_deployment" "main" {
  metadata {
    name      = "${var.name}-traefik"
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
        service_account_name             = kubernetes_service_account.main.metadata.0.name
        termination_grace_period_seconds = 60

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "ingress-ready"
                  operator = "In"
                  values   = ["true"]
                }
              }
            }
          }
        }

        toleration {
          effect   = "NoSchedule"
          key      = "node-role.kubernetes.io/master"
          operator = "Equal"
        }

        container {
          image = "${var.traefik-image.image}:${var.traefik-image.tag}"
          name  = var.name

          security_context {
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }

          args = concat([
            "--api.insecure",
            "--api.dashboard",
            # Specify that we want to use Traefik as an Ingress Controller.
            "--providers.kubernetesingress",
            "--providers.kubernetesingress.ingressclass=traefik",
            # Define two entrypoint ports, and setup a redirect from HTTP to HTTPS.
            "--entryPoints.web.address=:80",
            "--entryPoints.websecure.address=:443",
            "--entrypoints.web.http.redirections.entryPoint.to=websecure",
            "--entrypoints.web.http.redirections.entryPoint.scheme=https",
            # Enable debug logging. Useful to work out why something might not be
            # working. Fetch logs of the pod.
            "--log.level=${var.loglevel}",
            ], var.enable-certificates ? [
            "--certificatesresolvers.default.acme.tlschallenge",
            "--certificatesresolvers.default.acme.email=${var.acme-email}",
            "--certificatesresolvers.default.acme.storage=acme.json",
            "--certificatesresolvers.default.acme.caserver=${var.acme-server}",
          ] : [])

          port {
            name           = "http"
            container_port = 80
          }

          port {
            name           = "https"
            container_port = 443
          }

          port {
            name           = "dashboard"
            container_port = 8080
          }
        }
      }
    }
  }
}
