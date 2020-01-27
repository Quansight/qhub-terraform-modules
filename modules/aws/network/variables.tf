variable "name" {
  description = "Prefix name to give to network resources"
  type = string
}

variable "tags" {
  description = "Additional tags to apply to network resources"
  type = map(string)
  default = {}
}

variable "vpc_additional_tags" {
  description = "Additional tags to apply specifically to vpc"
  type = map(string)
  default = {}
}

variable "vpc_subnet_additional_tags" {
  description = "Additional tags to apply specifically to vpc subnet"
  type = map(string)
  default = {}
}

variable "aws_availability_zones" {
  description = "AWS Availability zones to operate infrastructure"
  type = list(string)
}

variable "vpc_cidr_block" {
  description = "VPC cidr for subnets to inside of"
  type = string
}
