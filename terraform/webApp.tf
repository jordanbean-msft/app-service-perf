resource "azurerm_app_service_plan" "appServicePlan" {
  name                = "appsp-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "appService" {
  name                = "app-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  app_service_plan_id = azurerm_app_service_plan.appServicePlan.id
  https_only          = true
  enabled             = true
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.appInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appInsights.connection_string
  }
}

resource "azurerm_monitor_diagnostic_setting" "appServiceLogging" {
  name                       = "appServiceLogging"
  target_resource_id         = azurerm_app_service_plan.appServicePlan.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
  log {
    category = "AppServiceConsoleLogs"
  }
  log {
    category = "AppServiceEnvironmentPlatformLogs"
  }
  log {
    category = "AppServiceFileAuditLogs"
  }
  metric {
    category = "AllMetrics"
  }
}