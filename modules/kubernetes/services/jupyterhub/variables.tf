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
    namespace = string     # default spawner namespace
    image = string         # default spawner jupyterlab image
    cpu_guarantee = number # default spawner jupyterlab guaranteed cpu
    cpu_limit = number     # default spawner jupyterlab max cpus
    mem_guarantee = number # default spawner jupyterlab guaranteed memory
    mem_limit = number     # default spawner jupyterlab max memory
    default_url = string   # default spawner jupyterlab url
  })
  default = {
    namespace = "default"
    image = "quansight/qhub-jupyterlab:e26a2766a0a66ce6d4c538f9f550b1f267f3d240"
    cpu_guarantee = "1.0"
    cpu_limit = "1.0"
    memory_guarantee = "1G"
    mem_limit = "1G"
    default_url = "/lab"
    pod_name_template = "jupyter-{username}--{servername}"
  }
}

variable "hub-node-group" {
  description = "Node key value pair for bound jupyterhub deployment"
  type = object({
    key   = string
    value = string
  })
}

variable "proxy-node-group" {
  description = "Node group key value pair for bound user resources"
  type = object({
    key   = string
    value = string
  })
}

variable "jupyterlab-node-group" {
  description = "Node group key value pair for bound worker resources"
  type = object({
    key   = string
    value = string
  })
}

variable "services" {
  description = "services to create api tokens"
  type        = list(string)
  default     = []
}

variable "extraConfig" {
  description = "Additional jupyterhub configuration"
  type        = string
  default     = ""
}
