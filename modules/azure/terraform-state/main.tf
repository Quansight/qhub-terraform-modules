provider azurerm {
  features {}
}

resource "azurerm_resource_group" "terraform-resource-group" {
  name     = "${var.name}-terraform-state"
  location = var.location
}

resource "azurerm_storage_account" "terraform-storage-account" {
  name                     = var.name  # must be unique across the entire Azure service
  resource_group_name      = azurerm_resource_group.terraform-resource-group.name
  location                 = azurerm_resource_group.terraform-resource-group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "${var.name}state"
  storage_account_name  = azurerm_storage_account.terraform-storage-account.name
  container_access_type = "private"
}
