output "public_key" {
  description = "Public key to verify that kubessh connection"
  value       = tls_private_key.kubessh_private_key.public_key_pem
}

output "service" {
  description = "Service needed for nginx-ingress tcp proxy"
  value = {
    port      = 22
    name      = var.name
    namespace = var.namespace
  }
}
