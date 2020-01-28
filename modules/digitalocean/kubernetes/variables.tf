variable "name" {
  description = "Prefix name to assign to digital ocean kubernetes cluster"
  type = string
}

variable "tags" {
  description = "Additional tags to apply to each kuberentes resource"
  type = map(string)
}

variable "region" {
  description = "Region to deploy digital ocean kuberentes resource"
  type = string
  default = "nyc1"
}

variable "version" {
  description = "Version of digital ocean kuberentes resource"
  type = string
  default = "1.16.2-do.2"
}

variable "node_groups" {
  description = "List of node groups to include in digital ocean kubernetes cluster"
  type = list(map(any))
}
