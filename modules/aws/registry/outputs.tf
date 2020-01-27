output "registry_url" {
  description = "Docker registry url for image"
  value = aws_ecr_repository.main.repository_url
}
