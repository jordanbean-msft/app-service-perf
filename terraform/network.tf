resource "azurerm_virtual_network" "vNet" {
  name                = "vnet-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "appServiceSubnet" {
  name                 = "appServiceSubnet"
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.vNet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Web", "Microsoft.Storage"]
}

resource "azurerm_monitor_diagnostic_setting" "vNetLogging" {
  name                       = "vNetLogging"
  target_resource_id         = azurerm_virtual_network.vNet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
  log {
    category = "VMProtectionAlerts"
  }
  metric {
    category = "AllMetrics"
  }
}