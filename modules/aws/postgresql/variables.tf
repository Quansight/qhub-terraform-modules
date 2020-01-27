variable "name" {
  description = "Prefix name to assign to AWS RDS postgresql database"
  type = string
}

variable "tags" {
  description = "Additional tags to assign to AWS RDS postgresql database"
  type = map(string)
  default = {}
}

variable "postgresql_instance_type" {
  description = "AWS Instance type for postgresql instance"
  type = string
  default = "db.r4.large"
}

variable "postgresql_number_instances" {
  description = "AWS number of postgresql instances"
  type = number
  default = 1
}

variable "postgresql_master_username" {
  description = "Postgresql master username"
  type = string
}

variable "postgresql_master_password" {
  description = "Postgresql master password"
  type = string
}

variable "postgresql_master_database" {
  description = "Postgresql master database"
  type = string
}

variable "postgresql_additional_users" {
  description = "Additional Postgresql users"
  type = list(object({
    username = string
    password = string
    database = string
  }))
}

variable "postgresql_extensions" {
  description = "Postgresql extensions to enable"
  type = list(string)
  default = [ ]
}
