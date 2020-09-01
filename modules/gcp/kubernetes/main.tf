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
