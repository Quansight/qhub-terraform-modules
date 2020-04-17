variable "name" {
  description = "Prefix name form nfs server kubernetes resource"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy nfs server"
  type        = string
}

variable "nfs_capacity" {
  description = "Capacity of NFS server deployment"
  type        = string
  default     = "10Gi"
}
