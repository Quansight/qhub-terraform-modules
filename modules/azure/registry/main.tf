provider azurerm {
  features {}
}
resource "azurerm_resource_group" "resource-group" {
  name     = "${var.name}-container-registry"
  location = var.location
}

resource "azurerm_container_registry" "container_registry" {
  name                = var.name
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location
  sku                 = "Standard"
  # admin_enabled       = true
}