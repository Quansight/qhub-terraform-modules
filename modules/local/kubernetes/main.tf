provider "kind" {}

resource "kind_cluster" "default" {
    name = var.name
}
