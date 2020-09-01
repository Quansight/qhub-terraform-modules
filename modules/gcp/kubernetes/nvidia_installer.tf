resource "kubernetes_daemonset" "nvidia_installer" {
  count = length(concat([for node_group in var.merged_nodegroups : nodegroup.guest_accelerators])) == 0 ? 0 : 1

  metadata {
    name      = "nvidia-driver-installer"
    namespace = "kube-system"
    labels = {
      "k8s-app" = "nvidia-driver-installer"
    }
  }

  spec {
    selector {
      match_labels = {
        "k8s-app" = "nvidia-driver-installer"
      }
    }

    strategy = {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          name      = "nvidia-driver-installer"
          "k8s-app" = "nvidia-driver-installer"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              nodeSelectorTerms = [
                {
                  match_expressions = [
                    {
                      key      = "cloud.google.com/gke-accelerator"
                      operator = Exists
                    }
                  ]
                }
              ]
            }
          }
        }
        toleration = [
          {
            operator = Exists
          }
        ]
        host_network = true
        host_pid     = true
        init_container = [
          {
            image = "gcr.io/cos-cloud/cos-gpu-installer@sha256:8d86a652759f80595cafed7d3dcde3dc53f57f9bc1e33b27bc3cfa7afea8d483"
            name  = "nvidia-driver-installer"
            resources = {
              requests = {
                cpu = 0.15
              }
            }
            security_context = {
              privileged = true
            }
            env = [
              {
                name  = "NVIDIA_INSTALL_DIR_HOST"
                value = "/home/kubernetes/bin/nvidia"
              },
              {
                name  = "NVIDIA_INSTALL_DIR_CONTAINER"
                value = "/usr/local/nvidia"
              },
              {
                name  = "VULKAN_ICD_DIR_HOST"
                value = "/home/kubernetes/bin/nvidia/vulkan/icd.d"
              },
              {
                name  = "VULKAN_ICD_DIR_CONTAINER"
                value = "/etc/vulkan/icd.d"
              },
              {
                name  = "ROOT_MOUNT_DIR"
                value = "/root"
              },
            ]
            volume_mounts = [
              {
                name  = "NVIDIA_INSTALL_DIR_HOST"
                value = "/home/kubernetes/bin/nvidia"
              },
              {
                name  = "NVIDIA_INSTALL_DIR_HOST"
                value = "/home/kubernetes/bin/nvidia"
              },
              {
                name  = "NVIDIA_INSTALL_DIR_HOST"
                value = "/home/kubernetes/bin/nvidia"
              },
              {
                name  = "NVIDIA_INSTALL_DIR_HOST"
                value = "/home/kubernetes/bin/nvidia"
              },
            ]
          }
        ]
        container {
          image = "gcr.io/google-containers/pause:2.0"
          name  = "pause"
        }
      }
    }
  }
}
