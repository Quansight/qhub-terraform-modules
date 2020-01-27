output "credentials" {
  description = "Important credentials for connecting to S3 bucket"
  value = {
    bucket = aws_s3_bucket.main.bucket_domain_name
  }
}
