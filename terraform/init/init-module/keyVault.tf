resource "azurerm_key_vault" "keyVault" {
  name                            = "kv${var.shortName}"
  resource_group_name             = var.resourceGroup.name
  location                        = var.resourceGroup.location
  enable_rbac_authorization       = true
  sku_name                        = "standard"
  enabled_for_template_deployment = true
  tenant_id                       = var.tenantId
}
