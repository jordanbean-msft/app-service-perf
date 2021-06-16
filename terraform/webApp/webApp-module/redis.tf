resource "azurerm_redis_cache" "redisCache" {
  name                = "redis-${var.longName}"
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"
}

resource "azurerm_monitor_diagnostic_setting" "redisCacheLogging" {
  name                       = "redisCacheLogging"
  target_resource_id         = azurerm_redis_cache.redisCache.id
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

resource "azurerm_key_vault_secret" "cacheCredentialSecret" {
  name         = "cacheCredentials"
  key_vault_id = var.keyVault.id
  value        = azurerm_redis_cache.redisCache.primary_connection_string
}

# delay needed here