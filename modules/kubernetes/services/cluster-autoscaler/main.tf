resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

data "helm_repository" "autoscaler" {
  name = "stable"
  url  = "https://charts.helm.sh/stable"
}

resource "helm_release" "autoscaler" {
  name      = "cluster-autoscaler"
  namespace = var.namespace

  repository = data.helm_repository.autoscaler.metadata[0].name
  chart      = "stable/cluster-autoscaler"
  version    = "7.1.0"

  values = concat([
    jsonencode({
      rbac = {
        create = true
      }

      cloudProvider = "aws"
      awsRegion     = var.aws-region

      autoDiscovery = {
        clusterName = var.cluster-name
        enabled     = true
      }
    })
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
