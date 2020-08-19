variable "name" {
  description = "name prefix to assign to jupyterhub"
  default = "terraform-jupyterhub"
}

variable "namespace" {
  description = "namespace to deploy jupyterhub"
  default = "default"
}
