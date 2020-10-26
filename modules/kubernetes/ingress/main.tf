resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

resource "helm_release" "ingress" {
  name      = "ingress"
  namespace = var.namespace

  chart = "${path.module}/chart"

  values = concat([
    file("${path.module}/chart/values.yaml"),
    jsonencode({
      "cert-manager" = {
        affinity = local.affinity

        cainjector = {
          affinity = local.affinity
        }

        webhook = {
          affinity = local.affinity
        }
      }

      "nginx-ingress" = {
        controller = {
          affinity = local.affinity
          livenessProbe = {
            timeoutSeconds = 20
          }
        }

        defaultBackend = {
          affinity = local.affinity
        }
      }
    }),
  ], var.overrides)

  depends_on = [
    null_resource.dependency_getter
  ]
}

data "kubernetes_service" "ingress" {
  depends_on = [helm_release.ingress]

  metadata {
    name      = "ingress-nginx-ingress-controller"
    namespace = var.namespace
  }
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    helm_release.ingress
    # List resource(s) that will be constructed last within the module.
  ]
}
