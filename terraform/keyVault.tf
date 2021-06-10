resource "azurerm_key_vault" "keyVault" {
  name                            = "kv${local.shortName}"
  resource_group_name             = azurerm_resource_group.resourceGroup.name
  location                        = azurerm_resource_group.resourceGroup.location
  enable_rbac_authorization       = true
  sku_name                        = "standard"
  enabled_for_template_deployment = true
  tenant_id                       = var.WEBAPPTENANTID
}

resource "azurerm_role_assignment" "pipelineKeyVaultAdministratorRole" {
  scope                = azurerm_key_vault.keyVault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.PIPELINEOBJECTID
}

resource "time_sleep" "waitForRbacPropagation" {
  create_duration = "30s"
  depends_on = [
    azurerm_role_assignment.pipelineKeyVaultAdministratorRole
  ]
}

resource "azurerm_key_vault_secret" "webAppClientSecret" {
  name         = "webAppClientSecret"
  key_vault_id = azurerm_key_vault.keyVault.id
  value        = var.WEBAPPCLIENTSECRET
  depends_on = [
    time_sleep.waitForRbacPropagation
  ]
}