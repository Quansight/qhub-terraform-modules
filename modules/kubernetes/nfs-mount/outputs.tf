output "persistent_volume_claim" {
  description = "Name of persistent volume claim"
  value = {
    name      = "nfs-server-share-${var.namespace}"
    namespace = var.namespace
  }
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}
