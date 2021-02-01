output "endpoint" {
  description = "traefik load balancer endpoint"
  value       = kubernetes_service.main.status.0.load_balancer.0.ingress.0
}
