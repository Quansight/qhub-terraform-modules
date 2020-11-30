output "credentials" {
  description = "Credentials needs to connect to kubernetes instance"
  value = {
    endpoint = kind_cluster.main.endpoint
    client_certificate = kind_cluster.main.client_certificate
    client_key = kind_cluster.main.client_key
    cluster_ca_certificate = kind_cluster.main.cluster_ca_certificate
    kubeconfig = kind_cluster.main.kubeconfig
    kubeconfig_path = kind_cluster.main.kubeconfig_path
    token = kind_cluster.main.token
  }
}
