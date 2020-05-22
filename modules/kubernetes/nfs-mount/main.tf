resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

resource "kubernetes_storage_class" "main" {
  metadata {
    name = "${var.name}-${var.namespace}-share"
  }

  storage_provisioner = "kubernetes.io/fake-nfs"
  depends_on          = [null_resource.dependency_getter]
}


resource "kubernetes_persistent_volume" "main" {
  metadata {
    name = "${var.name}-${var.namespace}-share"
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
  depends_on = [null_resource.dependency_getter]
}


resource "kubernetes_persistent_volume_claim" "main" {
  metadata {
    name      = "${var.name}-${var.namespace}-share"
    namespace = var.namespace
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.main.metadata.0.name
    resources {
      requests = {
        storage = var.nfs_capacity
      }
    }
  }
  depends_on = [null_resource.dependency_getter]
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    # List resource(s) that will be constructed last within the module.
  ]
}
