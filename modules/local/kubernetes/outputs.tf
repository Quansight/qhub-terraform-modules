output "credentials" {
  description = "Credentials needs to connect to kubernetes instance"
  value = {
    endpoint = kind_cluster.default.endpoint
  }
}
