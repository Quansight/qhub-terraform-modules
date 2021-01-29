output "endpoint" {
  description = "traefik load balancer endpoint"
  value       = data.kubernetes_service.main.status.0.load_balancer.0.ingress.0
}
