resource "tls_private_key" "kubessh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "kubessh_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.kubessh_private_key.private_key_pem"
}

resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

data "helm_repository" "kubessh" {
  name = "kubessh"
  url  = "https://chart.kubessh.org"
}

resource "helm_release" "kubessh" {
  name      = var.name
  namespace = var.namespace

  repository = data.helm_repository.kubessh.metadata[0].name
  chart      = "kubessh"
  version    = "0.0.1-n001.h2068e92"

  values = concat([
    file("${path.module}/values.yaml")
  ], var.overrides)

  depends_on = [
    null_resource.dependency_getter
  ]
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    # List resource(s) that will be constructed last within the module.
  ]
}
