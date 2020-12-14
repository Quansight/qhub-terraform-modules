variable "dependencies" {
  description = "A list of module dependencies to be injected in the module"
  type        = list(any)
  default     = []
}
