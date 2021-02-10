
variable "name" {
  description = "Prefix name to assign to azure kubernetes cluster"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to each kuberentes resource"
  type        = map
  default     = {}
}

variable "node_labels" {
  description = "Additional tags to apply to each node pool"
  type        = map
  default     = {}
}

# `az account list-locations`
variable "location" {
  description = "Location for GCP Kubernetes cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of kuberenetes"
  type        = string
  # default     = "1.18.14"
}

variable "node_pools" {
  description = "Node groups to add to Azure Kubernetes Cluster"
  type        = list(map(any))
  default = [
    {
      name          = "user"
      instance_type = "Standard_DS2_v2"
      min_size      = 0
      max_size      = 2
    },
    {
      name          = "worker"
      instance_type = "Standard_DS2_v2"
      min_size      = 0
      max_size      = 5
    }
  ]
}
