resource "kubernetes_persistent_volume_claim" "main" {
  metadata {
    name = "nfs-server-storage"
    namespace = "kube-system"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.nfs_capacity
      }
    }
  }
}


resource "kubernetes_service" "main" {
  metadata {
    name = "nfs-server"
  }

  spec {
    selector = {
      role = "nfs-server"
    }

    port {
      name = "nfs"
      port = 2049
    }

    port {
      name = "mountd"
      port = 20048
    }

    port {
      name = "rpcbind"
      port = 111
    }
  }
}


resource "kubernetes_deployment" "main" {
  metadata {
    name = "nfs-server"
    namespace = "kube-system"
    labels = {
      role = "nfs-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        role = "nfs-server"
      }
    }

    template {
      metadata {
        labels = {
          role = "nfs-server"
        }
      }

      spec {
        container {
          name = "nfs-server"
          image = "gcr.io/google_containers/volume-nfs:0.8"

          port {
            name = "nfs"
            container_port = 2049
          }

          port {
            name = "mountd"
            container_port = 20048
          }

          port {
            name = "rpcbind"
            container_port = 111
          }

          security_context {
            privileged = true
          }

          volume_mount {
            mount_path = "/exports"
            name = "nfs-export-fast"
          }
        }

        volume {
          name = "nfs-export-fast"
          persistent_volume_claim {
            claim_name = "nfs-server-storage"
          }
        }
      }
    }
  }
}
