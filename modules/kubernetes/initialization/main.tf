resource "kubernetes_namespace" "main" {
  metadata {
    labels = {
      mylabel = "label-value"
    }

    name = var.namespace
  }
}


resource "kubernetes_secret" "main" {
  metadata {
    name      = "test-secret"
    namespace = var.namespace
  }

  data = {
    username = "admin"
    password = "P4ssw0rd"
  }

  type = "Opaque"
}
