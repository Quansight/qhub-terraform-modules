resource "kubernetes_config_map" "main" {
  metadata {
    name = "${var.name}-config"
    namespace = var.namespace
  }

  data = {
    "jupyterhub_config.py" = templatefile("${path.module}/jupyterhub_config.py", {

    })
  }
}
