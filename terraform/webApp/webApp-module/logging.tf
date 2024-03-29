resource "azurerm_application_insights" "appInsights" {
  name                = "ai-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "appInsightsSmartDetection" {
  name                = "appInsightsSmartDetection"
  resource_group_name = var.resourceGroup.name
  enabled             = true
  short_name          = "SmartDetect"
  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }
  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "allExceptionsMetricAlert" {
  name                = "allExceptionsMetricAlert"
  resource_group_name = var.resourceGroup.name
  scopes = [
    azurerm_application_insights.appInsights.id
  ]
  severity = 3
  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.appInsightsSmartDetection.id
  }
}

resource "azurerm_log_analytics_workspace" "logAnalyticsWorkspace" {
  name                = "log-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
}