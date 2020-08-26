output "jupyterhub_api_token" {
  description = "api token to enable in jupyterhub server"
  value       = random_password.jupyterhub_api_token.result
}

output "config" {
  description = "dask gateway /etc/dask/dask-gateway.yaml configuration"
  value = {
    gateway = {
      address         = "http://web-public-${var.name}"
      "proxy-address" = "scheduler-public-${var.name}:8786"

      auth = {
        type = "jupyterhub"
      }
    }
  }
}
