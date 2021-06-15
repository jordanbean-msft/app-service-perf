resource "azurerm_network_profile" "networkProfile" {
  name = "networkProfile"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location = azurerm_resource_group.resourceGroup.location
  container_network_interface {
    name = "containerNetworkInterface"
    ip_configuration {
      name = "containerNetworkInterfaceIpConfiguration"
      subnet_id = azurerm_subnet.adoAgentSubnet.id
    }
  }
}

resource "azurerm_container_group" "containerGroup" {
  name = "cgadoagent"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location = azurerm_resource_group.resourceGroup.location
  count = 1
  os_type = "Linux"
  ip_address_type = "private"
  network_profile_id = azurerm_network_profile.networkProfile.id
  image_registry_credential {
    username = azurerm_container_registry.containerRegistry.admin_username
    password = azurerm_container_registry.containerRegistry.admin_password
    server = azurerm_container_registry.containerRegistry.login_server
  }
  container {
    name = "adoagent"
    image = "crappserviceperfussccentral.azurecr.io/crappserviceperfussccentral/linux:ubuntu-16.04"
    cpu = 1
    memory = 1.0
    ports {
        port = 443
        protocol = "TCP"
    }
    environment_variables = {
      "AZP_URL" = var.azpUrl
      "AZP_POOL" = var.azpPool
      "AZP_TOKEN" = var.azpToken
    }
  }
}