module "kubernetes-jupyterhub" {
  source = "../../jupyterhub"

  namespace = var.namespace

  overrides = concat(var.jupyterhub-overrides, [
    jsonencode({
      hub = {
        nodeSelector = {
          "${var.general-node-group.key}" = var.general-node-group.value
        }

        services = {
          "dask-gateway" = {
            apiToken = module.kubernetes-dask-gateway.jupyterhub_api_token
          }
        }
      }

      scheduling = {
        userScheduler = {
          nodeSelector = {
            "${var.user-node-group.key}" = var.user-node-group.value
          }
        }
      }

      proxy = {
        nodeSelector = {
          "${var.general-node-group.key}" = var.general-node-group.value
        }
      }

      singleuser = {
        nodeSelector = {
          "${var.user-node-group.key}" = var.user-node-group.value
        }

        image = {
          name = var.user-image.name
          tag  = var.user-image.tag
        }

        storage = {
          static = {
            pvcName = var.home-pvc
          }

          extraVolumes = [
            {
              name = "etc-dask"
              configMap = {
                name = kubernetes_config_map.dask-etc.metadata.0.name
              }
            }
          ]

          extraVolumeMounts = [
            {
              name      = "etc-dask"
              mountPath = "/etc/dask"
            },
            {
              name      = "home"
              mountPath = "/home/shared"
              subPath   = "home/shared"
            }
          ]
        }
      }
    })
  ])
}

module "kubernetes-dask-gateway" {
  source = "../../dask-gateway"

  namespace = var.namespace

  external_endpoint = "https://${var.external-url}"

  overrides = [
    jsonencode({
      gateway = {
        clusterManager = {
          image = {
            name = var.user-image.name
            tag  = var.user-image.tag
          }

          scheduler = {
            extraPodConfig = {
              affinity = local.affinity.worker-nodegroup
            }
          }
          worker = {
            extraPodConfig = {
              affinity = local.affinity.worker-nodegroup
            }
          }
        }
      }
    })
  ]
}

resource "kubernetes_config_map" "dask-etc" {
  metadata {
    name      = "dask-etc"
    namespace = var.namespace
  }

  data = {
    "gateway.yaml"   = jsonencode(module.kubernetes-dask-gateway.config)
    "dashboard.yaml" = jsonencode({})
  }
}

resource "kubernetes_ingress" "dask-gateway" {
  metadata {
    name      = "dask-gateway"
    namespace = var.namespace

    annotations = {
      "cert-manager.io/cluster-issuer"              = "letsencrypt-production"
      "kubernetes.io/ingress.class"                 = "nginx"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }

  spec {
    rule {
      host = var.external-url
      http {
        path {
          backend {
            service_name = "web-public-dask-gateway"
            service_port = 80
          }

          path = "/gateway"
        }

        path {
          backend {
            service_name = "proxy-public"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      secret_name = "qhub-cert"
      hosts       = [var.external-url]
    }
  }
}
