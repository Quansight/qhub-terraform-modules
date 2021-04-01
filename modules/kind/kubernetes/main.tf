resource "kind_cluster" "main" {
  name           = var.name
  wait_for_ready = true
  node_image     = "kindest/node:v1.19.1@sha256:98cf5288864662e37115e362b23e4369c8c4a408f99cbc06e58ac30ddc721600"
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    node {
      role = "control-plane"
      kubeadm_config_patches = [
        <<-YAML
                kind: InitConfiguration
                nodeRegistration:
                  kubeletExtraArgs:
                    node-labels: "ingress-ready=true"
                YAML
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 8080
        host_port      = 8080
        protocol       = "TCP"
      }
    }
    node {
      role = "worker"
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
      role = "worker"
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
      role = "worker"
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
