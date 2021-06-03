resource "azurerm_application_insights" "appInsights" {
  name                = "ai-${var.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  application_type    = "web"
}