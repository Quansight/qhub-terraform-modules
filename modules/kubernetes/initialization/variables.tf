variable "namespace" {
  description = "Namespace for all resources deployed"
  type = string
}

variable "labels" {
  description = "Additional labs to apply for all resources deployed"
  type = map(string)
}
