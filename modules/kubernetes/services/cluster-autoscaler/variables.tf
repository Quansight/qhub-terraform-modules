variable "namespace" {
  description = "Namespace for helm chart resource"
  type        = string
}

variable "cluster-name" {
  description = "Cluster name for kuberentes cluster"
  type        = string
}

variable "aws-region" {
  description = "AWS Region that cluster autoscaler is running"
  type        = string
}

variable "overrides" {
  description = "Helm overrides to apply"
  type        = list(string)
  default     = []
}

variable "dependencies" {
  description = "A list of module dependencies to be injected in the module"
  type        = list(any)
  default     = []
}
