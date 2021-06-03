resource "azurerm_application_insights" "appInsights" {
  name                = "ai-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "logAnalyticsWorkspace" {
  name                = "log-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
}