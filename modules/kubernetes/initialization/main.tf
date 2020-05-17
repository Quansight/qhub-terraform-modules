resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    labels = merge({}, var.labels)

    name = var.namespace
  }
  depends_on = [null_resource.dependency_getter]
}


resource "kubernetes_secret" "main" {
  count = length(var.secrets)

  metadata {
    name      = var.secrets[count.index].name
    namespace = var.namespace
    labels    = merge({}, var.labels)
  }

  data = var.secrets[count.index].data

  type       = "Opaque"
  depends_on = [null_resource.dependency_getter]
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    kubernetes_namespace.main,
    kubernetes_secret.main
    # List resource(s) that will be constructed last within the module.
  ]
}
