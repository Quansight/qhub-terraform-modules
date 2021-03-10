resource "tls_private_key" "kubessh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "helm_repository" "kubessh" {
  name = "kubessh"
  url  = "https://chart.kubessh.org"
}

resource "helm_release" "kubessh" {
  name      = var.name
  namespace = var.namespace

  repository = data.helm_repository.kubessh.metadata[0].name
  chart      = "kubessh"
  version    = "0.0.1-n001.h2068e92"

  values = concat([
    jsonencode({
      hostKey = tls_private_key.kubessh_private_key.private_key_pem

      service = {
        type     = "ClusterIP"
        port     = 22
        nodePort = 22
      }
    }),
  ], var.overrides)
}
