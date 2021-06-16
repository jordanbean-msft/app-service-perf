resource "azurerm_virtual_network" "vNet" {
  name                = "vnet-${var.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  address_space       = [var.addressSpace]
}

resource "azurerm_subnet" "appServiceSubnet" {
  name                 = "appServiceSubnet"
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.vNet.name
  address_prefixes     = ["10.${var.blockId}.1.0/24"]
  service_endpoints    = ["Microsoft.Web", "Microsoft.Storage"]
  delegation {
    name = "appServiceDelegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

data "azurerm_virtual_network" "centralVirtualNetwork" {
  name                = var.centralVirtualNetworkName
  resource_group_name = var.centralResourceGroupName
}

resource "azurerm_virtual_network_peering" "vNetPeeringFromCentral" {
  name                      = "vNetPeeringFromCentralTo${var.environment}"
  resource_group_name       = var.centralResourceGroupName
  virtual_network_name      = data.azurerm_virtual_network.centralVirtualNetwork.name
  remote_virtual_network_id = azurerm_virtual_network.vNet.id
}

resource "azurerm_virtual_network_peering" "vNetPeeringToCentral" {
  name                      = "vNetPeeringToCentralFrom${var.environment}"
  resource_group_name       = azurerm_resource_group.resourceGroup.name
  virtual_network_name      = azurerm_virtual_network.vNet.name
  remote_virtual_network_id = data.azurerm_virtual_network.centralVirtualNetwork.id
}

resource "azurerm_network_security_group" "appServiceSubnetNSG" {
  name                = "appServiceSubnetNSG"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  security_rule = [
    {
      access                                     = "Allow"
      description                                = "Allow traffic from central vNet"
      destination_address_prefix                 = "10.${var.blockId}.1.0/24"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "443"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "allowTrafficFromCentralvNet"
      priority                                   = 100
      protocol                                   = "Tcp"
      source_address_prefix                      = var.centralAdoAgentAddressPrefix
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
    },
    {
      access                                     = "Deny"
      description                                = "Deny all other traffic"
      destination_address_prefix                 = "10.${var.blockId}.1.0/24"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "*"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "denyAllOtherTraffic"
      priority                                   = 200
      protocol                                   = "*"
      source_address_prefix                      = "*"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
    }
  ]
}

# resource "azurerm_monitor_diagnostic_setting" "vNetLogging" {
#   name                       = "vNetLogging"
#   target_resource_id         = azurerm_virtual_network.vNet.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
#   log {
#     category = "VMProtectionAlerts"
#     enabled  = true
#     retention_policy {
#       days    = 0
#       enabled = true
#     }
#   }
#   metric {
#     category = "AllMetrics"
#     enabled  = true
#     retention_policy {
#       days    = 0
#       enabled = true
#     }
#   }
# }