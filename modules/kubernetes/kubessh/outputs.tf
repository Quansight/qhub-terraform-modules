output "jupyterhub_api_token" {
  description = "API token to enable in jupyterhub server"
  value       = random_password.jupyterhub_api_token.result
}

output "config" {
  description = "kubessh configuration"
  value = {
    "public-address" = var.external_endpoint
  }
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}
