resource "kubernetes_config_map" "main" {
  metadata {
    name = "my-config-example"
    namespace = var.namespace
  }

  data = {
    "my_config_file.yml" = templatefile("${path.module}/jupyterhub_config.py", {

    })
  }
}
