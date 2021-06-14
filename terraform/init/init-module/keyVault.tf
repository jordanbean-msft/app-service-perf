resource "azurerm_key_vault" "keyVault" {
  name                            = "kv${var.shortName}"
  resource_group_name             = azurerm_resource_group.resourceGroup.name
  location                        = azurerm_resource_group.resourceGroup.location
  enable_rbac_authorization       = true
  sku_name                        = "standard"
  enabled_for_template_deployment = true
  tenant_id                       = var.tenantId
}
