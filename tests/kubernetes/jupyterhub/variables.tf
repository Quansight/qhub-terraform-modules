variable "name" {
  description = "name prefix to assign to jupyterhub"
  default = "terraform-jupyterhub"
}

variable "namespace" {
  description = "namespace to deploy jupyterhub"
  default = "default"
}

variable "hub_storage" {
  description = "storage to allocate for jupyterhub"
  default     = "1Gi"
}

variable "hub-image" {
  description = "hub image"
  type = object({
    image = string
    tag = string
  })
  default = {
    image = "jupyterhub/k8s-hub"
    tag   = "0.9.1"
  }
}

variable "services" {
  description = "services to add to jupyterhub cluster"
  type = list(object({
    name = string
    api_key = string
  }))
}
