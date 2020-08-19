variable "name" {
  description = "name prefix to assign to daskgateway"
  type = string
  default = "terraform-daskgateway"
}

variable "namespace" {
  description = "namespace to deploy daskgateway"
  type = string
}

variable "gateway-image" {
  description = "dask gateway image to use"
  type = object({
    image = string
    tag = string
  })
  default = {
    image = "daskgateway/dask-gateway-server"
    tag   = "0.8.0"
  }
}

variable "controller-image" {
  description = "dask gateway image to use"
  type = object({
    image = string
    tag = string
  })
  default = {
    image = "daskgateway/dask-gateway-server"
    tag   = "0.8.0"
  }
}
