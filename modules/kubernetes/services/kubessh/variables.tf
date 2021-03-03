variable "name" {
  description = "Name for helm chart kubessh deployment"
  type        = string
  default     = "kubessh"
}

variable "namespace" {
  description = "Namespace for kubessh deployment"
  type        = string
}

variable "overrides" {
  description = "kubessh helm chart list of overrides"
  type        = list(string)
  default     = []
}
