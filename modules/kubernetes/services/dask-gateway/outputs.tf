output "jupyterhub_api_token" {
  description = "API token to enable in jupyterhub server"
  value       = random_password.jupyterhub_api_token.result
}

output "config" {
  description = "Dask gateway /etc/dask/dask-gateway.yaml configuration"
  value = {
    gateway = {
      address          = "http://web-public-${var.name}"
      "proxy-address"  = "scheduler-public-${var.name}:8786"
      "public-address" = var.external_endpoint

      auth = {
        type = "jupyterhub"
      }
    }
  }
}
