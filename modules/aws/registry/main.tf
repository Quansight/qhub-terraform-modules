resource "aws_ecr_repository" "main" {
  name = "${var.name}-ecr"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge({ Name = "${var.name}-ecr" }, var.tags)
}
