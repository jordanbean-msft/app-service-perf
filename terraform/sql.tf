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

resource "azurerm_mssql_database" "sqlServerDatabase" {
  name      = "sqldb-${local.longName}"
  server_id = azurerm_mssql_server.sqlServer.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "Basic"
}

resource "azurerm_monitor_diagnostic_setting" "dbLogging" {
  name = "dbLogging"
  target_resource_id = azurerm_mssql_database.sqlServerDatabase.id
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