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

  namespace            = var.namespace
  jupyterhub_api_token = random_password.jupyterhub_api_token.result
  jupyterhub_api_url   = "http://proxy-public.${var.namespace}/hub/api"

  external-url = var.external-url

  cluster-image    = var.dask-worker-image
  gateway-image    = var.dask-gateway-image
  controller-image = var.dask-gateway-image

  general-node-group = var.general-node-group
  worker-node-group  = var.worker-node-group

  # default cluster behavior
  cluster = {
    # scheduler configuration
    scheduler_cores        = 1
    scheduler_cores_limit  = 1
    scheduler_memory       = "2 G"
    scheduler_memory_limit = "2 G"
    scheduler_extra_container_config = {
      volumeMounts = [
        {
          name      = "conda-store"
          mountPath = "/home/conda"
        }
      ]
    }
    scheduler_extra_pod_config = {
      affinity = local.affinity.worker-nodegroup
      volumes = [
        {
          name = "conda-store"
          persistentVolumeClaim = {
            claimName = var.conda-store-pvc
          }
        }
      ]
    }
    # worker configuration
    worker_cores        = 1
    worker_cores_limit  = 1
    worker_memory       = "2 G"
    worker_memory_limit = "2 G"
    worker_extra_container_config = {
      volumeMounts = [
        {
          name      = "conda-store"
          mountPath = "/home/conda"
        }
      ]
    }
    worker_extra_pod_config = {
      affinity = local.affinity.worker-nodegroup
      volumes = [
        {
          name = "conda-store"
          persistentVolumeClaim = {
            claimName = var.conda-store-pvc
          }
        }
      ]
    }
    # additional fields
    image_pull_policy = "IfNotPresent"
    environment       = {}
  }

  extra_config = var.dask_gateway_extra_config
}


module "kubernetes-jupyterhub-ssh" {
  source = "../../jupyterhub-ssh"

  namespace          = var.namespace
  jupyterhub_api_url = "http://proxy-public.${var.namespace}"

  node-group              = var.general-node-group
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


resource "kubernetes_manifest" "jupyterhub" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "jupyterhub"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`${var.external-url}`) && (Path(`/`) || PathPrefix(`/hub`) || PathPrefix(`/user`) || PathPrefix(`/services`))"
          services = [
            {
              name = "proxy-public"
              port = 80
            }
          ]
        }
      ]
      tls = local.tls
    }
  }
}

resource "kubernetes_manifest" "dask-gateway" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "dask-gateway"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`${var.external-url}`) && PathPrefix(`/gateway/`)"

          middlewares = [
            {
              name      = "qhub-dask-gateway-gateway-api"
              namespace = var.namespace
            }
          ]

          services = [
            {
              name = "qhub-dask-gateway-gateway-api"
              port = 8000
            }
          ]
        }
      ]
      tls = local.tls
    }
  }
}

resource "kubernetes_manifest" "jupyterhub-ssh-ingress" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "jupyterhub-ssh-ingress"
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
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "jupyterhub-sftp-ingress"
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
