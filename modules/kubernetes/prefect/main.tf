module "prefect" {
  source = "."
  dependencies = var.dependencies
  jupyterhub_api_token = var.jupyterhub_api_token
  environment = var.environment
  prefect_token = var.prefect_token
}

