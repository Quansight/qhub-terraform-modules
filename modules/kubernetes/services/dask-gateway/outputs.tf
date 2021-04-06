output "config" {
  description = "dask gateway /etc/dask/dask-gateway.yaml configuration"
  value = {
    gateway = {
      address         = "http://${kubernetes_service.gateway.metadata.0.name}.${kubernetes_service.gateway.metadata.0.namespace}:8000"

      auth = {
        type = "jupyterhub"
      }
    }
  }
}
