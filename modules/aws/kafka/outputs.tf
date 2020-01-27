output "zookeeper_connect_string" {
  description = "Zookeeper connection host:port pairs"
  value       = aws_msk_cluster.main.zookeeper_connect_string
}

output "bootstrap_brokers" {
  description = "Kafka Plaintext connection host:port pairs"
  value       = aws_msk_cluster.main.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "Kafka TLS connection host:port pairs"
  value       = aws_msk_cluster.main.bootstrap_brokers_tls
}
