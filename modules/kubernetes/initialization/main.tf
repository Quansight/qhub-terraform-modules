resource "kubernetes_namespace" "main" {
  metadata {
    labels = {
      mylabel = "label-value"
    }

    name = var.namespace
  }
}


resource "kubernetes_secret" "main" {
  count = length(var.secrets)

  metadata {
    name      = var.secrets[count.index].name
    namespace = var.namespace
  }

  data = var.secrets[count.index].data

  type = "Opaque"
}
