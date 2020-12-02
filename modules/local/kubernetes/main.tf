resource "kind_cluster" "main" {
    name = var.name
    wait_for_ready = true
    node_image = "kindest/node:v1.16.15@sha256:a89c771f7de234e6547d43695c7ab047809ffc71a0c3b65aa54eda051c45ed20"
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
