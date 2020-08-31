data "google_client_config" "main" {
}

resource "google_container_cluster" "main" {
  name     = var.name
  location = var.location

  node_locations = var.availability_zones

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "main" {
  count = length(var.merged_node_groups)

  name     = var.merged_node_groups[count.index].name
  location = var.location
  cluster  = google_container_cluster.main.name

  initial_node_count = min(var.merged_node_groups[count.index].min_size, 1)

  autoscaling {
    min_node_count = var.merged_node_groups[count.index].min_size
    max_node_count = var.merged_node_groups[count.index].max_size
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.merged_node_groups[count.index].preemptible
    machine_type = var.merged_node_groups[count.index].instance_type

    service_account = google_service_account.main.email

    oauth_scopes = local.node_group_oauth_scopes

    metadata = {
      disable-legacy-endpoints = "true"
    }

    dynamic "guest_accelerator" {
      for_each = var.merged_node_groups[count.index].guest_accelerators

      content {
        name  = guest_accelerator.name
        count = guest_accelerator.count
      }
    }
  }
}

resource "kubernetes_daemonset" "nvidia_installer" {
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
