resource "kubernetes_storage_class" "main" {
  metadata {
    name = "nfs-class"
  }

  storage_provisioner = "kubernetes.io/fake-nfs"
}


resource "kubernetes_persistent_volume" "main" {
  metadata {
    name = "nfs-server-share-${var.namespace}"
  }
  spec {
    capacity = {
      storage = var.nfs_capacity
    }
    storage_class_name = "nfs-class"
    access_modes       = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        path   = "/"
        server = var.nfs_endpoint
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "main" {
  metadata {
    name      = "nfs-server-share-${var.namespace}"
    namespace = var.namespace
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-class"
    resources {
      requests = {
        storage = var.nfs_capacity
      }
    }
  }
}
