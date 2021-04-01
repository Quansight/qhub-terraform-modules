output "annotations" {
  description = "ingress annotations"
  value = {
    "kubernetes.io/ingress.class"                 = "nginx"
    "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
  }
}
