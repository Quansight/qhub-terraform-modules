resource "kind_cluster" "main" {
    name = var.name
    wait_for_ready = true
    node_image = "kindest/node:v1.18.8@sha256:f4bcc97a0ad6e7abaf3f643d890add7efe6ee4ab90baeb374b4f41a4c95567eb"
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
            extra_port_mappings {
                container_port = 80
                host_port = 80
                protocol = "TCP"
            }
            extra_port_mappings {
                container_port = 443
                host_port = 443
                protocol = "TCP"
            }
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
