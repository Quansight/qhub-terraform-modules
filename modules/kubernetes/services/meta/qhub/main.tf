resource "random_password" "jupyterhub_api_token" {
  length  = 32
  special = false
}


module "kubernetes-jupyterhub" {
  source = "../../jupyterhub"

  namespace = var.namespace

  overrides = concat(var.jupyterhub-overrides, [
    jsonencode({
      hub = {
        nodeSelector = {
          (var.general-node-group.key) = var.general-node-group.value
        }

        image = var.jupyterhub-image

        services = {
          "dask-gateway" = {
            apiToken = random_password.jupyterhub_api_token.result
          }
        }
      }

      scheduling = {
        userScheduler = {
          nodeSelector = {
            (var.general-node-group.key) = var.general-node-group.value
          }
        }
      }

      proxy = {
        nodeSelector = {
          (var.general-node-group.key) = var.general-node-group.value
        }
      }

      singleuser = {
        nodeSelector = {
          (var.user-node-group.key) = var.user-node-group.value
        }

        image = var.jupyterlab-image

        storage = {
          static = {
            pvcName = var.home-pvc
          }

          extraVolumes = [
            {
              name = "conda-store"
              persistentVolumeClaim = {
                claimName = var.conda-store-pvc
              }
            },
            {
              name = "etc-dask"
              configMap = {
                name = kubernetes_config_map.dask-etc.metadata.0.name
              }
            }
          ]

          extraVolumeMounts = [
            {
              name      = "conda-store"
              mountPath = "/home/conda"
            },
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
  jupyterhub_api_token = random_password.jupyterhub_api_token.result
  jupyterhub_api_url = "http://proxy-public.${var.namespace}/hub/api"

  cluster-image = var.dask-worker-image

  general-node-group = var.general-node-group
  worker-node-group = var.worker-node-group
}


module "kubernetes-jupyterhub-ssh" {
  source = "../../jupyterhub-ssh"

  namespace = var.namespace
  jupyterhub_api_url = "http://proxy-public.${var.namespace}"

  node-group = var.general-node-group
  persistent_volume_claim = var.home-pvc
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
      "kubernetes.io/ingress.class"                           = "traefik"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
    }
  }

  spec {
    rule {
      host = var.external-url
      http {
        path {
          backend {
            service_name = "proxy-public"
            service_port = 80
          }
          path = "/hub"
        }
        path {
          backend {
            service_name = "proxy-public"
            service_port = 80
          }
          path = "/user"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "jupyterhub-ssh-ingress" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind = "IngressRouteTCP"
    metadata = {
      name = "jupyterhub-ssh-ingress"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["ssh"]
      routes = [
        {
          match = "HostSNI(`*`)"
          services = [
            {
              name = "qhub-jupyterhub-ssh"
              port = 8022
            }
          ]
        }
      ]
    }
  }
}


resource "kubernetes_manifest" "jupyterhub-sftp-ingress" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind = "IngressRouteTCP"
    metadata = {
      name = "jupyterhub-sftp-ingress"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["sftp"]
      routes = [
        {
          match = "HostSNI(`*`)"
          services = [
            {
              name = "qhub-jupyterhub-sftp"
              port = 8023
            }
          ]
        }
      ]
    }
  }
}
