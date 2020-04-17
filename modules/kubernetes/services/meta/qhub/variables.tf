variable "name" {
  description = "Name for QHub Deployment"
  type        = string
}

variable "namespace" {
  description = "Namespace for QHub Deployment"
  type        = string
}

variable "home-pvc" {
  description = "Name for persistent volume claim to use for home directory uses /home/{username}"
  type        = string
}

variable "external-url" {
  description = "External url that jupyterhub cluster is accessible"
  type        = string
}

variable "user-image" {
  description = "Docker image to use for jupyterlab users and dask workers"
  type = object({
    name = string
    tag  = string
  })
}

variable "general-node-group" {
  description = "Node key value pair for bound general resources"
  type = object({
    key   = string
    value = string
  })
}

variable "user-node-group" {
  description = "Node group key value pair for bound user resources"
  type = object({
    key   = string
    value = string
  })
}

variable "worker-node-group" {
  description = "Node group key value pair for bound worker resources"
  type = object({
    key   = string
    value = string
  })
}

variable "jupyterhub-overrides" {
  description = "Jupyterhub helm overrides"
  type        = list(string)
}
