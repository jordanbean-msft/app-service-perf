resource "azurerm_storage_account" "storageAccount" {
  name                     = lower("st${var.appName}${var.region}${var.environment}")
  resource_group_name      = var.resourceGroup.name
  location                 = var.resourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
  min_tls_version          = "TLS1_2"
     network_rules {
       default_action             = "Deny"
       virtual_network_subnet_ids = [data.azurerm_subnet.appServiceSubnet.id]
       bypass                     = ["AzureServices"]
     }
}

resource "azurerm_storage_container" "storageAccountContainer" {
  name                  = var.storageAccountContainerImagesName
  storage_account_name  = azurerm_storage_account.storageAccount.name
  container_access_type = "private"
}

resource "azurerm_monitor_diagnostic_setting" "storageLogging" {
  name                       = "storageLogging"
  target_resource_id         = "${azurerm_storage_account.storageAccount.id}/blobServices/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
  log {
    category = "StorageRead"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "StorageWrite"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "StorageDelete"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  metric {
    category = "Transaction"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  metric {
    category = "Capacity"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
}

resource "azurerm_key_vault_secret" "storageAccountConnectionString" {
  name = "storageAccountConnectionString"
  key_vault_id = var.keyVault.id
  value = azurerm_storage_account.storageAccount.primary_connection_string
}