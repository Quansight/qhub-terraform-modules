provider "kubernetes" {
  config_context = "minikube"
}

provider "kubernetes-alpha" {
  version = "0.1.0"
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

  depends_on = [
    kubernetes_namespace.main
  ]
}

module "conda-store" {
  source = "../conda-store"

  name = var.prefix
  namespace = var.namespace

  depends_on = [
    kubernetes_namespace.main
  ]
}

# module "dask-gateway" {
#   source = "../dask-gateway"

#   name = var.prefix
#   namespace = var.namespace

#   depends_on = [
#     kubernetes_namespace.main
#   ]
# }

module "jupyterhub" {
  source = "../jupyterhub"

  name = var.prefix
  namespace = var.namespace

  depends_on = [
    kubernetes_namespace.main
  ]
}
