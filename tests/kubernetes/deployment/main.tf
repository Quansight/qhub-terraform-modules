provider "kubernetes-alpha" {
  config_context = "minikube"
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
  }
}

module "dask-gateway" {
  source = "../dask-gateway"

  name = "terraform-qhub-daskgateway"
  namespace = var.namespace
}

module "jupyterhub" {
  source = "../jupyterhub"

  name = "terraform-qhub-jupyterhub"
  namespace = var.namespace
}
