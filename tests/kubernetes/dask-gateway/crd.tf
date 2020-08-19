resource "kubernetes_manifest" "main" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1beta1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "daskclusters.gateway.dask.org"
    }
    spec = {
      group = "gateway.dask.org"
      names = {
        kind = "DaskCluster"
        list_kind = "DaskClusterList"
        plural = "daskclusters"
        singular = "daskcluster"
      }
      scope = "Namespaced"

      subresources = {
        status = {}
      }
    }
  }
}
