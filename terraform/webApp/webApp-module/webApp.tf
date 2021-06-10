resource "azurerm_app_service_plan" "appServicePlan" {
  name                = "appsp-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  sku {
    tier = "Free"
    size = "F1"
  }
}

data "azurerm_key_vault_secret" "cacheCredentialSecret" {
  name         = "cacheCredentials"
  key_vault_id = var.keyVault.id
  depends_on = [
    azurerm_key_vault_secret.cacheConnectionSecret
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
    APPINSIGHTS_INSTRUMENTATIONKEY            = azurerm_application_insights.appInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING     = azurerm_application_insights.appInsights.connection_string
    "AzureAD:Domain"                          = var.webAppDomain
    "AzureAD:ClientId"                        = var.webAppClientId
    "AzureAD:TenantId"                        = var.tenantId
    "AzureAD:ClientSecret"                    = "@Microsoft.KeyVault(VaultName=${var.keyVault.name};SecretName=${data.azurerm_key_vault_secret.webAppClientSecret.name})"
    "Storage:ServiceUri"                      = azurerm_storage_account.storageAccount.primary_blob_endpoint
    "ConnectionStrings:AppServicePerfContext" = "Server=tcp:${azurerm_mssql_server.sqlServer.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.sqlServerDatabase.name};"
    "ConnectionStrings:RedisCache"            = "@Microsoft.KeyVault(VaultName=${var.keyVault.name};SecretName=${data.azurerm_key_vault_secret.cacheCredentialSecret.name})"
    WEBSITE_RUN_FROM_PACKAGE                  = 1
  }
}

resource "azurerm_monitor_diagnostic_setting" "appServiceLogging" {
  name                       = "appServiceLogging"
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