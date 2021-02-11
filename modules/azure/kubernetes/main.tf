provider azurerm {
  features {}
}

resource "azurerm_resource_group" "qhub_resource_group" {
  name     = "qhub_resource_group"
  location = var.location
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = azurerm_resource_group.qhub_resource_group.location
  resource_group_name = azurerm_resource_group.qhub_resource_group.name

  # DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created.
  dns_prefix = "Qhub" # required

  # Azure requires that a new, non-existent Resource Group is used, as otherwise the provisioning of the Kubernetes Service will fail.
  node_resource_group = "node_resource_group" # optional
  default_node_pool {
    name                 = "general"
    node_count           = 1
    vm_size              = "Standard_D2_v2"
    # enable_auto_scaling  = "true"
    # min_count            = 1
    # max_count            = 1
    # node_labels          = var.node_labels
    # orchestrator_version = var.kubernetes_version
    # tags = {
    #   "azure-node-pool" = "general"
    # }
  }

  sku_tier = "Free" # "Free" [Default] or "Paid"

  identity {
    type = "SystemAssigned" # "UserAssigned" or "SystemAssigned".  SystemAssigned identity lifecycles are tied to the AKS Cluster.
  }

  # tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
resource "azurerm_kubernetes_cluster_node_pool" "node_groups" {
  count                 = length(var.node_groups)
  name                  = var.node_groups[count.index].name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.node_groups[count.index].instance_type
  node_count            = 0
  enable_auto_scaling   = "true"
  mode                  = "User" # "System" or "User", only "User" nodes can scale down to 0
  min_count             = var.node_groups[count.index].min_size
  max_count             = var.node_groups[count.index].max_size
  # tags                  = {
  #     "azure-node-pool" = var.node_groups[count.index].name
  #   }
  # orchestrator_version  = var.kubernetes_version
}
