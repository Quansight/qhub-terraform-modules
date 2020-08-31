variable "name" {
  description = "Prefix name for GCP Kubernetes cluster"
  type        = string
}

variable "availability_zones" {
  description = "Zones for Kubernetes cluster to be deployed in"
  type        = list(string)
}

variable "location" {
  description = "Location for GCP Kubernetes cluster"
  type        = string
}

variable "additional_node_group_roles" {
  description = "Additional roles to apply to each node group"
  type        = list(string)
  default     = []
}

variable "additional_node_group_oauth_scopes" {
  description = "Additional oauth scopes to apply to each node group"
  type        = list(string)
  default     = []
}

variable "node_groups" {
  description = "Node groups to add to GCP Kubernetes Cluster"
  type = list(map(any))
  default = [
    {
      name      = "general"
      instance  = "n1-standard-2"
      min_nodes = 1
      max_nodes = 1
    },
    {
      name      = "user"
      instance  = "n1-standard-2"
      min_nodes = 0
      max_nodes = 2
    },
    {
      name      = "worker"
      instance  = "n1-standard-2"
      min_nodes = 0
      max_nodes = 5
    }
  ]
}

variable "node_group_defaults" {
  description = "Node group default values"
  type = object({
    name               = string
    instance_type      = string
    min_size           = number
    max_size           = number
    guest_accelerators = list(object({
      type  = string
      count = number
    }))
  })
  default = {
    name = "node-group-default"
    instance = "n1-standard-2"
    min_nodes = 0
    max_nodes = 1
    # https://www.terraform.io/docs/providers/google/r/container_cluster.html#guest_accelerator
    guest_accelerators = [ ]
  }
}
