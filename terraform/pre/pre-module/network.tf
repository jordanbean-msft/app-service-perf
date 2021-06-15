resource "azurerm_virtual_network" "vNet" {
  name                = "vnet-central"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  address_space       = [var.addressSpace]
}

resource "azurerm_subnet" "adoAgentSubnet" {
  name                 = "adoAgentSubnet"
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.vNet.name
  address_prefixes     = [var.adoAgentAddressPrefix]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.Storage"]
  delegation {
    name = "containerGroupDelegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
    }
  }
}