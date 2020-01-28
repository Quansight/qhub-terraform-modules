resource "digitalocean_kubernetes_cluster" "main" {
  name    = "${var.cluster-name}-tf-cluster"
  region  = var.region

  # Grab the latest from `doctl kubernetes options versions`
  version = "1.16.2-do.2"

  node_pool {
    name       = local.master_node_group.name
    # List available regions `doctl kubernetes options sizes`
    size       = lookup(local.master_node_group, "size", "s-1vcpu-2gb")
    node_count = lookup(local.master_node_group, "node_count", 1)
  }

  tags = var.tags
}

resource "digitalocean_kubernetes_node_pool" "main" {
  count = length(local.additional_node_groups)

  cluster_id = digitalocean_kubernetes_cluster.main.id

  name       = local.additional_node_groups[count.index].name
  size       = lookup(local.additional_node_groups[count.index], "size", "s-1vcpu-2gb")

  auto_scale = true
  min_nodes = lookup(local.additional_node_groups[count.index], "min_nodes", 1)
  max_nodes = lookup(local.additional_node_groups[count.index], "max_nodes", 1)

  tags       = var.tags
}
