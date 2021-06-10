resource "azurerm_application_insights" "appInsights" {
  name                = "ai-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "logAnalyticsWorkspace" {
  name                = "log-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
}