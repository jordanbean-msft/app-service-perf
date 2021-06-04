resource "azurerm_key_vault" "keyVault" {
  name                            = "kv-${local.longName}"
  resource_group_name             = azurerm_resource_group.resourceGroup.name
  location                        = azurerm_resource_group.resourceGroup.location
  enable_rbac_authorization       = true
  sku_name                        = "standard"
  enabled_for_template_deployment = true
  tenant_id                       = var.webAppTenantId
}

resource "azurerm_key_vault_secret" "webAppClientSecret" {
  name         = "webAppClientSecret"
  key_vault_id = azurerm_key_vault.keyVault.id
  value        = var.webAppClientSecret
}