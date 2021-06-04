resource "azurerm_app_service_plan" "appServicePlan" {
  name                = "appsp-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "appService" {
  name                = "app-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  app_service_plan_id = azurerm_app_service_plan.appServicePlan.id
  https_only          = true
  enabled             = true
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.appInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appInsights.connection_string
    "AzureAD:Domain"                      = var.webAppDomain
    "AzureAD:ClientId"                    = var.webAppClientId
    "AzureAD:TenantId"                    = var.webAppTenantId
    "AzureAD:ClientSecret"                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.keyVault.name};SecretName=${azurerm_key_vault_secret.webAppClientSecret.name}"
    "Storage:ServiceUri"                  = azurerm_storage_account.storageAccount.primary_blob_endpoint
  }
}

resource "azurerm_monitor_diagnostic_setting" "appServiceLogging" {
  name                       = "appServiceLogging"
  target_resource_id         = azurerm_app_service_plan.appServicePlan.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalyticsWorkspace.id
  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_role_assignment" "managedIdentityWebAppKeyVaultSecretsUserRoleAssignment" {
  scope                = azurerm_key_vault.keyVault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_app_service.appService.identity[0].principal_id
}


resource "azurerm_role_assignment" "managedIdentityWebAppStorageRoleAssignment" {
  scope                = azurerm_storage_account.storageAccount.id
  role_definition_name = "Storage Account Blob Data Contributor"
  principal_id         = azurerm_app_service.appService.identity[0].principal_id
}

output "appServiceName" {
  value = azurerm_app_service.appService.name
}