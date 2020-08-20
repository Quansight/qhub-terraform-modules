provider "kubernetes" {
  config_context = "minikube"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
  }
}

module "traefik" {
  source = "../traefik"

  name = var.prefix
  namespace = var.namespace
}

module "conda-store" {
  source = "../conda-store"

  name = var.prefix
  namespace = var.namespace
}

# module "dask-gateway" {
#   source = "../dask-gateway"

#   name = "terraform-qhub-daskgateway"
#   namespace = var.namespace
# }

# module "jupyterhub" {
#   source = "../jupyterhub"

#   name = "terraform-qhub-jupyterhub"
#   namespace = var.namespace
# }
