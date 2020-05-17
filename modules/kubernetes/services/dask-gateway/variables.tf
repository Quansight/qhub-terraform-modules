variable "name" {
  description = "Name for helm chart dask-gateway deployment"
  type        = string
  default     = "dask-gateway"
}

variable "namespace" {
  description = "Namespace for dask-gateway deployment"
  type        = string
}

variable "external_endpoint" {
  description = "External endpoint of dask-gateway exposed"
  type        = string
}

variable "overrides" {
  description = "Dask-gateway helm chart list of overrides"
  type        = list(string)
  default     = []
}

variable "dependencies" {
  description = "A list of module dependencies to be injected in the module"
  type        = list(any)
  default     = []
}
