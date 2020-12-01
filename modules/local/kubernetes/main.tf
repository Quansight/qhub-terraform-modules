resource "kind_cluster" "main" {
    name = var.name
    kind_config  {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"
        node {
            role = "control-plane"
        }
        node {
            role =  "worker"
            node-group = "general"
        }
        node {
            role =  "worker"
            node-group = "user"
        }
        node {
            role =  "worker"
            node-group = "worker"
        }
    }
}
