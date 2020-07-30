output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}

output "jupyterhub_api_token" {
  description = "API token to enable in jupyterhub server"
  value       = module.kubernetes-dask-gateway.jupyterhub_api_token
}
