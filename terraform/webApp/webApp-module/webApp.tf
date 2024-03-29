resource "azurerm_app_service_plan" "appServicePlan" {
  name                = "appsp-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  sku {
    tier = "Standard"
    size = "S1"
  }
}

data "azurerm_key_vault_secret" "cacheCredentialSecret" {
  name         = "cacheCredentials"
  key_vault_id = var.keyVault.id
  depends_on = [
    azurerm_key_vault_secret.cacheCredentialSecret
  ]
}

data "azurerm_key_vault_secret" "sqlServerConnectionString" {
  name         = "sqlServerConnectionString"
  key_vault_id = var.keyVault.id
  depends_on = [
    azurerm_key_vault_secret.sqlServerConnectionString
  ]
}

data "azurerm_key_vault_secret" "storageAccountConnectionString" {
  name         = "storageAccountConnectionString"
  key_vault_id = var.keyVault.id
  depends_on = [
    azurerm_key_vault_secret.storageAccountConnectionString
  ]
}

data "azurerm_key_vault_secret" "webAppClientSecret" {
  name         = "webAppClientSecret"
  key_vault_id = var.keyVault.id
}

resource "azurerm_app_service" "appService" {
  name                = "app-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  app_service_plan_id = azurerm_app_service_plan.appServicePlan.id
  https_only          = true
  enabled             = true
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "AzureAD:ClientId"                                       = var.webAppClientId
    "AzureAD:ClientSecret"                                   = "@Microsoft.KeyVault(VaultName=${var.keyVault.name};SecretName=${data.azurerm_key_vault_secret.webAppClientSecret.name})"
    "AzureAD:Domain"                                         = var.webAppDomain
    "AzureAD:TenantId"                                       = var.tenantId
    "ConnectionStrings:AppServicePerfManagedIdentityContext" = "Server=tcp:${azurerm_mssql_server.sqlServer.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.sqlServerDatabase.name};"
    "ConnectionStrings:AppServicePerfSqlPasswordContext"     = "@Microsoft.KeyVault(VaultName=${var.keyVault.name};SecretName=${data.azurerm_key_vault_secret.sqlServerConnectionString.name})"
    "ConnectionStrings:RedisCache"                           = "@Microsoft.KeyVault(VaultName=${var.keyVault.name};SecretName=${data.azurerm_key_vault_secret.cacheCredentialSecret.name})"
    "ConnectionStrings:StorageAccount"                       = "@Microsoft.KeyVault(VaultName=${var.keyVault.name};SecretName=${data.azurerm_key_vault_secret.storageAccountConnectionString.name})"
    "Storage:ServiceUri"                                     = azurerm_storage_account.storageAccount.primary_blob_endpoint
    APPINSIGHTS_INSTRUMENTATIONKEY                           = azurerm_application_insights.appInsights.instrumentation_key
    APPINSIGHTS_PROFILERFEATURE_VERSION                      = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION                      = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING                    = azurerm_application_insights.appInsights.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION               = "~2"
    DiagnosticServices_EXTENSION_VERSION                     = "~3"
    FeatureFlagSql                                           = "MANAGED_IDENTITY",
    FeatureFlagStorage                                       = "MANAGED_IDENTITY"
    InstrumentationEngine_EXTENSION_VERSION                  = "~1"
    SnapshotDebugger_EXTENSION_VERSION                       = "~1"
    WEBSITE_RUN_FROM_PACKAGE                                 = 1
    XDT_MicrosoftApplicationInsights_BaseExtensions          = "~1"
    XDT_MicrosoftApplicationInsights_Java                    = "1"
    XDT_MicrosoftApplicationInsights_Mode                    = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS                  = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk              = "1"
  }
}

data "azurerm_subnet" "appServiceSubnet" {
  name                 = var.appServiceSubnetName
  resource_group_name  = var.resourceGroup.name
  virtual_network_name = var.vNetName
}

data "azurerm_subnet" "adoAgentSubnet" {
  name                 = var.adoAgentSubnetName
  resource_group_name  = var.centralResourceGroupName
  virtual_network_name = var.centralvNetName
}

resource "azurerm_app_service_virtual_network_swift_connection" "appServicePlanvNetIntegration" {
  app_service_id = azurerm_app_service.appService.id
  subnet_id      = data.azurerm_subnet.appServiceSubnet.id
}

resource "azurerm_monitor_diagnostic_setting" "appServicePlanLogging" {
  name                       = "appServicePlanLogging"
  target_resource_id         = azurerm_app_service_plan.appServicePlan.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "appServiceLogging" {
  name                       = "appServiceLogging"
  target_resource_id         = azurerm_app_service.appService.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
  log {
    category = "AppServiceAntivirusScanAuditLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceConsoleLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceAppLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceFileAuditLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceAuditLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceIPSecAuditLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServicePlatformLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
}

resource "azurerm_role_assignment" "managedIdentityWebAppKeyVaultSecretsUserRoleAssignment" {
  scope                = var.keyVault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_app_service.appService.identity[0].principal_id
}


resource "azurerm_role_assignment" "managedIdentityWebAppStorageRoleAssignment" {
  scope                = azurerm_storage_account.storageAccount.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_app_service.appService.identity[0].principal_id
}
