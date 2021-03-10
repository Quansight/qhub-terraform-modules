output "jupyterhub_api_token" {
  description = "API token to enable in jupyterhub server"
  value       = module.kubernetes-dask-gateway.jupyterhub_api_token
}
