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
  description = "dask gateway image to use for gateway"
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
  description = "dask gateway image to use for controller"
  type = object({
    image = string
    tag = string
  })
  default = {
    image = "daskgateway/dask-gateway-server"
    tag   = "0.8.0"
  }
}

variable "cluster-image" {
  description = "default dask gateway image to use for cluster"
  type = object({
    image = string
    tag = string
  })
  default = {
    image = "daskgateway/dask-gateway"
    tag   = "0.8.0"
  }
}

variable "gateway" {
  description = "gateway configuration"
  type = object({
    loglevel = string
    # Path prefix to serve dask-gateway api requests under
    # This prefix will be added to all routes the gateway manages
    # in the traefik proxy.
    prefix = string
  })
  default = {
    loglevel = "INFO"
    prefix = "/"
  }
}

variable "controller" {
  description = "controller configuration"
  type = object({
    loglevel = string
    # Max time (in seconds) to keep around records of completed clusters.
    # Default is 24 hours.
    completedClusterMaxAge = number
    # Time (in seconds) between cleanup tasks removing records of completed
    # clusters. Default is 5 minutes.
    completedClusterCleanupPeriod = number
    # Base delay (in seconds) for backoff when retrying after failures.
    backoffBaseDelay = number
    # Max delay (in seconds) for backoff when retrying after failures.
    backoffMaxDelay = number
    # Limit on the average number of k8s api calls per second.
    k8sApiRateLimit = number
    # Limit on the maximum number of k8s api calls per second.
    k8sApiRateLimitBurst = number
  })
  default = {
    loglevel = "INFO"
    completedClusterMaxAge = 86400
    completedClusterCleanupPeriod = 600
    backoffBaseDelay = 0.1
    backoffMaxDelay = 300
    k8sApiRateLimit = 50
    k8sApiRateLimitBurst = 100
  }
}

variable "cluster" {
  description = "dask gateway cluster defaults"
  type = object({
    # scheduler configuration
    scheduler_cores = number
    scheduler_cores_limit = number
    scheduler_memory = string
    scheduler_memory_limit = string
    scheduler_extra_container_config = map(any)
    scheduler_extra_pod_config = map(any)
    # worker configuration
    worker_cores = number
    worker_cores_limit = number
    worker_memory = string
    worker_memory_limit = string
    worker_extra_container_config = map(any)
    worker_extra_pod_config = map(any)
    # additional fields
    image_pull_policy = string
    environment = map(string)
  })
  default = {
    # scheduler configuration
    scheduler_cores = 1
    scheduler_cores_limit = 1
    scheduler_memory = "2 G"
    scheduler_memory_limit = "2 G"
    scheduler_extra_container_config = {}
    scheduler_extra_pod_config = {}
    # worker configuration
    worker_cores = 1
    worker_cores_limit = 1
    worker_memory = "2 G"
    worker_memory_limit = "2 G"
    worker_extra_container_config = {}
    worker_extra_pod_config = {}
    # additional fields
    image_pull_policy = "IfNotPresent"
    environment = {}
  }
}
