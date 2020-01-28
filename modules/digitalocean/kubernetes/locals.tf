local {
  master_node_group = var.node_groups[0]

  additional_node_groups = slice(var.node_groups, 1)
}
