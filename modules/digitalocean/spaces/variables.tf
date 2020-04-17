variable "name" {
  description = "Prefix name for bucket resource"
  type        = string
}

variable "region" {
  description = "Region for Digital Ocean bucket"
  type        = string
}

variable "public" {
  description = "Digital Ocean s3 bucket is exposed publicly"
  type        = bool
  default     = false
}
