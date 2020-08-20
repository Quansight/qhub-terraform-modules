resource "random_password" "jupyterhub_api_token" {
  length  = 32
  special = false
}


resource "kubernetes_config_map" "gateway" {
  metadata {
    name = "${var.name}-daskgateway-gateway"
    namespace = var.namespace
  }

  data = {
    "dask_gateway_config.py" = templatefile("${path.module}/templates/gateway_config.py", {

    })
  }
}


resource "kubernetes_service_account" "gateway" {
  metadata {
    name = "${var.name}-daskgateway-gateway"
    namespace = var.namespace
  }
}


resource "kubernetes_cluster_role" "gateway" {
  metadata {
    name = "${var.name}-daskgateway-gateway"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["gateway.dask.org"]
    resources  = ["daskclusters"]
    verbs = ["*"]
  }
}


resource "kubernetes_cluster_role_binding" "gateway" {
  metadata {
    name = "${var.name}-daskgateway-gateway"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_deployment.gateway.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_deployment.gateway.metadata.0.name
    namespace = var.namespace
  }
}


resource "kubernetes_deployment" "gateway" {
  metadata {
    name = "${var.name}-daskgateway-gateway"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "dask-gateway"
      }
    }

    template {
      metadata {
        labels = {
          app = "dask-gateway"
        }
      }

      spec {
        volume {
          name = "configmap"
          config_map {
            name = kubernetes_config_map.gateway.metadata.0.name
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
            value = random_password.jupyterhub_api_token.result
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
