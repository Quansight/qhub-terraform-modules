resource "aws_security_group" "main-cluster" {
  name = "${var.name}-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = merge({ Name = "${var.name}-security-group" }, var.tags)
}
