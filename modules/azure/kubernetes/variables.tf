
variable "name" {
  description = "Prefix name to assign to azure kubernetes cluster"
  type        = string
}

# `az account list-locations`
variable "location" {
  description = "Location for GCP Kubernetes cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of kuberenetes"
  type        = string
}

variable "environment" {
  description = "Location for GCP Kubernetes cluster"
  type        = string
}


variable "node_groups" {
  description = "Node pools to add to Azure Kubernetes Cluster"
  type        = list(map(any))
  # default = [
  #   {
  #     name          = "user"
  #     instance_type = "Standard_DS2_v2"
  #     min_size      = 0
  #     max_size      = 2
  #   },
  #   {
  #     name          = "worker"
  #     instance_type = "Standard_DS2_v2"
  #     min_size      = 0
  #     max_size      = 5
  #   }
  # ]
}

# variable "node_labels" {
#   description = "Additional tags to apply to each node pool"
#   type        = map
#   default     = {}
# }


# unused
# variable "tags" {
#   description = "Additional tags to apply to each kuberentes resource"
#   type        = map
#   default     = {}
# }

