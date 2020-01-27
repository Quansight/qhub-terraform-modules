resource "kubernetes_persistent_volume" "main" {
  metadata = {
    name = "nfs-share"
  }

  spec = {
    capacity                      = var.nfs_capacity
    accessModes                   = ["ReadWriteMany"]
    persistentVolumeRecliamPolicy = "Retain"
    nfs = {
      server = var.nfs_server_address
      path   = "/"
    }
  }
}
