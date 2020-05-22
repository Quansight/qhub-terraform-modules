variable "name" {
  description = "Prefix name form conda-store server kubernetes resource"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy conda-store server"
  type        = string
}

variable "nfs_capacity" {
  description = "Capacity of conda-store deployment"
  type        = string
  default     = "10Gi"
}
