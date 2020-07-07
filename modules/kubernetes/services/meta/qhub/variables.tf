variable "name" {
  description = "Name for QHub Deployment"
  type        = string
}

variable "namespace" {
  description = "Namespace for QHub Deployment"
  type        = string
}

variable "kubessh-namespace" {
  description = "Namespace for Kubessh"
  type        = string
}

variable "home-pvc" {
  description = "Name for persistent volume claim to use for home directory uses /home/{username}"
  type        = string
}

variable "conda-store-pvc" {
  description = "Name for persistent volume claim to use for conda-store directory"
  type        = string
}

variable "external-url" {
  description = "External url that jupyterhub cluster is accessible"
  type        = string
}

variable "jupyterhub-image" {
  description = "Docker image to use for jupyterhub hub"
  type = object({
    name = string
    tag  = string
  })
}

variable "jupyterlab-image" {
  description = "Docker image to use for jupyterlab users"
  type = object({
    name = string
    tag  = string
  })
}

variable "dask-worker-image" {
  description = "Docker image to use for dask worker image"
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

variable "kubessh-overrides" {
  description = "Dask Worker helm overrides"
  type        = list(string)
  default     = []
}

variable "dask-gateway-overrides" {
  description = "Dask Worker helm overrides"
  type        = list(string)
  default     = []
}

variable "dependencies" {
  description = "A list of module dependencies to be injected in the module"
  type        = list(any)
  default     = []
}
