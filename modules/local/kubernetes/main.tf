resource "kind_cluster" "main" {
    name = var.name
    wait_for_ready = true
    kind_config  {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"
        node {
            role = "control-plane"
        }
        node {
            role =  "worker"
            kubeadm_config_patches = [
                <<-YAML
                kind: JoinConfiguration
                nodeRegistration:
                  kubeletExtraArgs:
                    node-labels: "node-group=general"
                YAML
            ]
        }
        node {
            role =  "worker"
            kubeadm_config_patches = [
                <<-YAML
                kind: JoinConfiguration
                nodeRegistration:
                  kubeletExtraArgs:
                    node-labels: "node-group=user"
                YAML
            ]
        }
        node {
            role =  "worker"
            kubeadm_config_patches = [
                <<-YAML
                kind: JoinConfiguration
                nodeRegistration:
                  kubeletExtraArgs:
                    node-labels: "node-group=worker"
                YAML
            ]
        }
    }
}
