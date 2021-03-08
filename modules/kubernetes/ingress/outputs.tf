locals {
  ingress = kubernetes_service.main.status.0.load_balancer.0.ingress
}

output "endpoint" {
  description = "traefik load balancer endpoint"
  //  handles the case when ingress is empty list
  value = length(local.ingress) == 0 ? null : local.ingress.0
}

output "annotations" {
  description = "ingress annotations"
  value = {
    "kubernetes.io/ingress.class"                           = "traefik"
    "traefik.ingress.kubernetes.io/router.tls"              = "true"
    "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
  }
}
