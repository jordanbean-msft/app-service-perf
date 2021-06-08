resource "azurerm_redis_cache" "redisCache" {
  name                = "redis-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"
}

resource "azurerm_key_vault_secret" "cacheConnectionSecret" {
  name         = "CacheConnection"
  key_vault_id = azurerm_key_vault.keyVault.id
  value        = azurerm_redis_cache.redisCache.primary_connection_string
  depends_on = [
    time_sleep.waitForRbacPropagation
  ]
}