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
  app_settings ddddddd {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.appInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appInsights.connection_string
  }
  # site_config {
  #   ip_restriction = [
  #     {
  #       action                    = "Allow"
  #       name                      = "AllowVnet"
  #       priority                  = 1
  #       virtual_network_subnet_id = azurerm_subnet.appServiceSubnet.id
  #       ip_address                = null
  #       headers                   = null
  #       service_tag               = null
  #     }
  #   ]
  # }
}