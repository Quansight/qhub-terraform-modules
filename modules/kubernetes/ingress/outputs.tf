output "endpoint" {
  description = "Nginx ingress endpoint"
  value       = data.kubernetes_service.ingress.spec.0.cluster_ip
}
