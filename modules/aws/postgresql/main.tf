# =======================================================
# AWS RDS - PostgreSQL Setup
# =======================================================

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier = "${var.name}-postgresql-cluster"

  engine = "aurora-postgresql"

  database_name = var.postgresql_master_database
  master_username = var.postgresql_master_username
  master_password = var.postgresql_master_password

  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot = true
  iam_database_authentication_enabled = true
  # NOTE - this should be removed when not in dev mode to reduce risk of downtime
  apply_immediately = true

  tags = merge({
    Name = "${var.name}-postgresql"
    Description = "Aurora PSQL database for '${var.name}-postgresql-cluster'. Final destination for paintrace data and associated user information."
  }, var.tags)
}

resource "aws_rds_cluster_instance" "postgresql_instances" {
  count = 1
  identifier = "${var.name}-postgresql-cluster-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class = var.postgresql_instance_type
  publicly_accessible = true
  engine = "aurora-postgresql"
}
