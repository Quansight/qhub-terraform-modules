variable "name" {
  description = "name prefix to assign to jupyterhub"
  default     = "terraform-jupyterhub"
}

variable "namespace" {
  description = "namespace to deploy jupyterhub"
  default     = "default"
}

variable "hub-image" {
  description = "hub image"
  type = object({
    image = string
    tag   = string
  })
  default = {
    image = "jupyterhub/k8s-hub"
    tag   = "0.9.1"
  }
}

variable "services" {
  description = "services to create api tokens"
  type        = list(string)
  default     = []
}

variable "proxy-image" {
  description = "proxy image"
  type = object({
    image = string
    tag   = string
  })
  default = {
    image = "jupyterhub/configurable-http-proxy"
    tag   = "4.2.1"
  }
}

variable "singleuser" {
  description = "jupyterhub singleuser defaults"
  type = object({
    namespace = string
  })
  default = {
    namespace = "default"
  }
}

variable "extraConfig" {
  description = "Additional jupyterhub configuration"
  type        = string
  default     = ""
}
