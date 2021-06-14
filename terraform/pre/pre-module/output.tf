output "resourceGroupName" {
  value = azurerm_resource_group.resourceGroup.name
}

output "virtualNetworkName" {
  value = azurerm_virtual_network.vNet.name
}

output "adoAgentAddressPrefix" {
  value = var.adoAgentAddressPrefix
}