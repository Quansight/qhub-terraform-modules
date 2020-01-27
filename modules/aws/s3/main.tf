resource "aws_s3_bucket" "private" {
  bucket = "${var.cluster-name}-${var.environment}-private-bucket"
  acl = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "${var.cluster-name}-bucket"
    Environment = var.environment
    Description = "Private S3 bucket for ${var.cluster-name}-${var.environment} paintrace data."
  }
}

resource "aws_s3_bucket" "public" {
  bucket = "${var.cluster-name}-${var.environment}-public-bucket"
  acl = "public-read"

  tags = {
    Name = "${var.cluster-name}-${var.environment}-public-bucket"
    Environment = var.environment
    Description = "Public S3 bucket for ${var.cluster-name}-${var.environment} executables and binaries."
  }
}
