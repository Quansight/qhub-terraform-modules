output "persistent_volume_claim" {
  description = "Name of persistent volume claim"
  value = {
    name      = kubernetes_persistent_volume_claim.main.metadata.0.name
    namespace = var.namespace
  }
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}
