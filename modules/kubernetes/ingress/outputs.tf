output "endpoint" {
  description = "Nginx ingress endpoint"
  # might need to use "hostname" for aws
  value = data.kubernetes_service.ingress.status.0.load_balancer.0.ingress.0
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}
