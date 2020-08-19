provider "kubernetes" {
  config_context = "minikube"
}

resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "example-namespace"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "example"
  }
}
