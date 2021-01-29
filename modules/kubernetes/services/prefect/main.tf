//module "prefect" {
//  source = ""
//  dependencies = var.dependencies
//  jupyterhub_api_token = var.jupyterhub_api_token
//  environment = var.environment
//  prefect_token = var.prefect_token
//}

resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

resource "helm_release" "prefect" {
  name      = "prefect"
  namespace = var.environment
  chart     = "${path.module}/chart"

  set_sensitive {
    name  = "prefectToken"
    value = var.prefect_token
  }

  set_sensitive {
    name  = "jupyterHubToken"
    value = var.jupyterhub_api_token
  }

  depends_on = [
    null_resource.dependency_getter
  ]
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    helm_release.jupyterhub
    # List resource(s) that will be constructed last within the module.
  ]
}

