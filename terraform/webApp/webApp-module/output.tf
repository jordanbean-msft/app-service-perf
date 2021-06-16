output "appServiceName" {
  value = azurerm_app_service.appService.name
}

output "sqlServerName" {
  value = azurerm_mssql_server.sqlServer.name
}

output "sqlDatabaseName" {
  value = azurerm_mssql_database.sqlServerDatabase.name
}