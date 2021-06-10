resource "azurerm_resource_group" "resourceGroup" {
  name     = "rg-${var.longName}"
  location = var.location
}