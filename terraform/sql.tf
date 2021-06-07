resource "azurerm_mssql_server" "sqlServer" {
  name                         = lower("sql-${local.longName}")
  resource_group_name          = azurerm_resource_group.resourceGroup.name
  location                     = azurerm_resource_group.resourceGroup.location
  version                      = "12.0"
  administrator_login          = var.sqlServerAdminUsername
  administrator_login_password = var.sqlServerAdminPassword
  minimum_tls_version          = "1.2"
  azuread_administrator {
    login_username = "AzureAD admin"
    object_id      = var.azureAdAdminObjectId
  }
}

resource "azurerm_mssql_firewall_rule" "sqlServerFirewallRule" {
  name                = "sqlServerFirewallRule"
  server_id           = azurerm_mssql_server.sqlServer.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mssql_database" "sqlServerDatabase" {
  name      = "sqldb-${local.longName}"
  server_id = azurerm_mssql_server.sqlServer.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "Basic"
}

resource "azurerm_monitor_diagnostic_setting" "dbLogging" {
  name                       = "dbLogging"
  target_resource_id         = azurerm_mssql_database.sqlServerDatabase.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
  log {
    category = "SQLInsights"
  }
  log {
    category = "AutomaticTuning"
  }
  log {
    category = "QueryStoreRuntimeStatistics"
  }
  log {
    category = "QueryStoreWaitStatistics"
  }
  log {
    category = "Errors"
  }
  log {
    category = "DatabaseWaitStatistics"
  }
  log {
    category = "Timeouts"
  }
  log {
    category = "Blocks"
  }
  log {
    category = "Deadlocks"
  }
  metric {
    category = "Basic"
  }
  metric {
    category = "InstanceAndAppAdvanced"
  }
  metric {
    category = "WorkloadManagement"
  }
}

resource "azurerm_key_vault_secret" "sqlServerAdminUsername" {
  name         = "sqlServerAdminUsername"
  key_vault_id = azurerm_key_vault.keyVault.id
  value        = var.sqlServerAdminUsername
}

resource "azurerm_key_vault_secret" "sqlServerAdminPassword" {
  name         = "sqlServerAdminPassword"
  key_vault_id = azurerm_key_vault.keyVault.id
  value        = var.sqlServerAdminPassword
}