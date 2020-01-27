output "aws_postgresql_master_connection" {
  description = "connection string for master database connection"
  value = {
    username = aws_rds_cluster.postgresql.master_username
    password = aws_rds_cluster.postgresql.master_password
    database = aws_rds_cluster.postgresql.database_name
    host = aws_rds_cluster_instance.cluster_instances[0].endpoint
    post = aws_rds_cluster.postgresql.port
  }
}

output "aws_postgresql_user_connections" {
  description = "Database connections and iam users for each database"
}
