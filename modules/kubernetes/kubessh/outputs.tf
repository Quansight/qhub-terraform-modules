output "config" {
  description = "kubessh configuration"
  value = {
    "public-address" = var.external_endpoint
  }
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}
