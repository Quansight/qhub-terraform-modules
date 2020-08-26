output "api_tokens" {
  description = "Jupyterhub API Tokens for services"
  value       = zipmap(
    var.services,
    [for instance in random_password.api_token: instance.result])
}

output "internal_proxy_url" {
  description = "Jupyterhub API URL"
  value = "http://${kubernetes_service.proxy_public.metadata.0.name}:80"
}
