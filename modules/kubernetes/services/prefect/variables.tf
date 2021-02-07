variable "jupyterhub_api_token" {
  type    = string
  default = ""
}

variable "namespace" {
  type    = string
  default = ""
}

variable "prefect_token" {
  type    = string
  default = ""
}

variable "dependencies" {
  description = "A list of module dependencies to be injected in the module"
  type        = list(any)
  default     = []
}
