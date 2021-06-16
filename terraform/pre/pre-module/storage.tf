resource "azurerm_storage_account" "storageAccount" {
  name                     = lower("sa${var.appName}${var.environment}")
  resource_group_name      = azurerm_resource_group.resourceGroup.name
  location                 = azurerm_resource_group.resourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
  min_tls_version          = "TLS1_2"
  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = [azurerm_subnet.adoAgentSubnet.id]
    bypass                     = ["AzureServices"]
  }
}

resource "azurerm_storage_container" "storageAccountContainer" {
  name                  = "ado-agent"
  storage_account_name  = azurerm_storage_account.storageAccount.name
  container_access_type = "private"
}