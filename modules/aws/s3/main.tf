resource "aws_s3_bucket" "private" {
  bucket = "${var.name}-bucket"
  acl    = var.public ? "public-read" : "private"

  versioning {
    enabled = true
  }

  tags = merge({
    Name        = "${var.name}-bucket"
    Description = "S3 bucket for ${var.name}"
  }, var.tags)
}
