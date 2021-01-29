output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}
