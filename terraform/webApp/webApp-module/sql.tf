resource "azurerm_mssql_server" "sqlServer" {
  name                         = lower("sql-${var.longName}")
  resource_group_name          = var.resourceGroup.name
  location                     = var.resourceGroup.location
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
  name             = "sqlServerFirewallRule"
  server_id        = azurerm_mssql_server.sqlServer.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "sqlServerDatabase" {
  name      = "sqldb-${var.longName}"
  server_id = azurerm_mssql_server.sqlServer.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "Basic"
}

resource "azurerm_monitor_diagnostic_setting" "dbLogging" {
  name                       = "dbLogging"
  target_resource_id         = azurerm_mssql_database.sqlServerDatabase.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
  log {
    category = "DevOpsOperationsAudit"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SQLInsights"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AutomaticTuning"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "QueryStoreRuntimeStatistics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "QueryStoreWaitStatistics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "Errors"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "DatabaseWaitStatistics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "Timeouts"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "Blocks"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "Deadlocks"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  metric {
    category = "Basic"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  metric {
    category = "InstanceAndAppAdvanced"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  metric {
    category = "WorkloadManagement"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
}

resource "azurerm_key_vault_secret" "sqlServerConnectionString" {
  name         = "sqlServerConnectionString"
  key_vault_id = var.keyVault.id
  value        = "Server=tcp:${azurerm_mssql_server.sqlServer.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.sqlServerDatabase.name};User ID=${var.sqlServerAdminUsername};Password=${var.sqlServerAdminPassword};"
}