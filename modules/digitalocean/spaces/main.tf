resource "digitalocean_spaces_bucket" "main" {
  name   = var.name
  region = var.region

  acl = (var.public ? "public-read" : "private")
}
