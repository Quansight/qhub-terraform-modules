resource "kubernetes_config_map" "controller" {
  metadata {
    name      = "${var.name}-daskgateway-controller"
    namespace = var.namespace
  }

  data = {
    "dask_gateway_config.py" = templatefile(
      "${path.module}/templates/controller_config.py", {
        gatewayName      = kubernetes_service.gateway.metadata.0.name
        gatewayNamespace = kubernetes_service.gateway.metadata.0.namespace
        gateway          = var.gateway
        controller       = var.controller
    })
  }
}

resource "kubernetes_service_account" "controller" {
  metadata {
    name      = "${var.name}-daskgateway-controller"
    namespace = var.namespace
  }
}


resource "kubernetes_cluster_role" "controller" {
  metadata {
    name = "${var.name}-daskgateway-controller"
  }

  rule {
    api_groups = ["gateway.dask.org"]
    resources  = ["daskclusters", "daskclusters/status"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["traefik.containo.us"]
    resources  = ["ingressroutes", "ingressroutetcps"]
    verbs      = ["get", "create", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets", "services"]
    verbs      = ["create", "delete"]
  }
}


resource "kubernetes_cluster_role_binding" "controller" {
  metadata {
    name = "${var.name}-daskgateway-controller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_deployment.controller.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_deployment.controller.metadata.0.name
    namespace = var.namespace
  }
}


resource "kubernetes_service" "controller" {
  metadata {
    name      = "${var.name}-dask-gateway-controller-api"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "dask-gateway-controller"
    }

    port {
      name        = "api"
      protocol    = "TCP"
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "controller" {
  metadata {
    name      = "${var.name}-daskgateway-controller"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "dask-gateway-controller"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "dask-gateway-controller"
        }

        annotations = {
          # This lets us autorestart when the secret changes!
          "checksum/config-map" = sha256(jsonencode(kubernetes_config_map.controller.data))
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = var.general-node-group.key
                  operator = "In"
                  values   = [var.general-node-group.value]
                }
              }
            }
          }
        }

        service_account_name            = kubernetes_service_account.controller.metadata.0.name
        automount_service_account_token = true

        volume {
          name = "configmap"
          config_map {
            name = kubernetes_config_map.controller.metadata.0.name
          }
        }

        container {
          image = "${var.controller-image.name}:${var.controller-image.tag}"
          name  = "${var.name}-daskgateway-controller"

          command = [
            "dask-gateway-server",
            "kube-controller",
            "--config",
            "/etc/dask-gateway/dask_gateway_config.py"
          ]

          volume_mount {
            name       = "configmap"
            mount_path = "/etc/dask-gateway/"
          }

          port {
            name           = "api"
            container_port = 8000
          }
        }
      }
    }
  }
}
