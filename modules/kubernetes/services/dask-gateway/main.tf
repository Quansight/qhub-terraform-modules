data "helm_repository" "dask-gateway" {
  name = "dask-gateway"
  url  = "https://dask.org/dask-gateway-helm-repo/"
}

resource "random_password" "cookie_secret_token" {
  length  = 32
  special = false
}

resource "random_password" "proxy_secret_token" {
  length  = 32
  special = false
}

resource "random_password" "jupyterhub_api_token" {
  length  = 32
  special = false
}

resource "helm_release" "dask-gateway" {
  name      = var.name
  namespace = var.namespace

  repository = data.helm_repository.dask-gateway.metadata[0].name
  chart      = "dask-gateway"
  version    = "0.9.0"

  values = concat([
    file("${path.module}/values.yaml")
  ], var.overrides)

  set {
    name  = "gateway.cookieSecret"
    value = random_password.cookie_secret_token.result
  }

  set {
    name  = "gateway.secretToken"
    value = random_password.proxy_secret_token.result
  }

  set {
    name  = "gateway.auth.jupyterhub.apiToken"
    value = random_password.jupyterhub_api_token.result
  }
}
