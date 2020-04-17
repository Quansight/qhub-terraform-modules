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
        }

        defaultBackend = {
          affinity = local.affinity
        }
      }
    }),
  ], var.overrides)
}

data "kubernetes_service" "ingress" {
  depends_on = [helm_release.ingress]

  metadata {
    name      = "ingress-nginx-ingress-controller"
    namespace = var.namespace
  }
}
