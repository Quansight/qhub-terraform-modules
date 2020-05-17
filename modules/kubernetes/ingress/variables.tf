variable "namespace" {
  description = "Namespace to deploy kubernetes ingress"
  type        = string
}

variable "node-group" {
  description = "Node group to associate ingress deployment"
  type = object({
    key   = string
    value = string
  })
}

variable "overrides" {
  description = "Overrides for values.yaml in helm configuration"
  type        = list(string)
  default     = []
}

variable "dependencies" {
  description = "A list of module dependencies to be injected in the module"
  type        = list(any)
  default     = []
}
