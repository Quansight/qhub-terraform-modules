resource "kind_cluster" "main" {
    name = var.name
    kind_config  {
        kind = "Cluster"
        node {
            role = "control-plane"
        }
        node {
            role =  "worker"
        }
        node {
            role =  "worker"
        }
    }
}
