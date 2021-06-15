resource "azurerm_application_insights" "appInsights" {
  name                = "ai-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  application_type    = "web"
  tags = {
    "hidden-link:${var.azurerm_resource_group.resourceGroup.id}/providers/Microsoft.Web/sites/app-${var.appName}-${var.region}-${var.environment}" : "Resource"
  }
}

resource "azurerm_log_analytics_workspace" "logAnalyticsWorkspace" {
  name                = "log-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
}