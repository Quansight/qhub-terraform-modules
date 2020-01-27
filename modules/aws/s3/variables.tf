variable "name" {
  description = "Prefix name for bucket resource"
  type = string
}

variable "tags" {
  description = "Additional tags to include with AWS S3 bucket"
  type = map(string)
  default = {}
}
