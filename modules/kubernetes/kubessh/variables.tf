variable "name" {
  description = "Name for helm chart kubessh deployment"
  type        = string
  default     = "kubessh"
}

variable "key_name" {
  description = "Name of private key"
  type        = string
  default     = "kubessh_key"
}

variable "namespace" {
  description = "Namespace for kubessh deployment"
  type        = string
}

variable "external_endpoint" {
  description = "External endpoint of kubessh exposed"
  type        = string
}

variable "overrides" {
  description = "kubessh helm chart list of overrides"
  type        = list(string)
  default     = []
}

variable "dependencies" {
  description = "A list of module dependencies to be injected in kubessh"
  type        = list(any)
  default     = []
}
