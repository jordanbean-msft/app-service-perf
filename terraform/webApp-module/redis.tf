resource "azurerm_redis_cache" "redisCache" {
  name                = "redis-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"
}

resource "azurerm_key_vault_secret" "cacheConnectionSecret" {
  name         = "cacheConnection"
  key_vault_id = var.keyVault.id
  value        = azurerm_redis_cache.redisCache.primary_connection_string
}