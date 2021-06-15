resource "azurerm_container_registry" "containerRegistry" {
  name = lower("cr${var.shortName}")
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location = azurerm_resource_group.resourceGroup.location
  admin_enabled = true
  sku = "Basic"
}