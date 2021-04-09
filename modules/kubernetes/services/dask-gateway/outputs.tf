output "config" {
  description = "dask gateway /etc/dask/dask-gateway.yaml configuration"
  value = {
    gateway = {
      address       = "https://${var.external-url}/gateway"
      proxy_address = "tcp://${var.external-url}:8786"

      auth = {
        type = "jupyterhub"
      }
    }
  }
}
