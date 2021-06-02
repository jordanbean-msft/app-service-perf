terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "terraformaiarjb"
    container_name       = "tfstate"
    key                  = "tfstate.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "resourceGroup" {
  name     = "rg-${local.longName}"
  location = var.location
}

resource "azurerm_storage_account" "storageAccount" {
  name                     = lower("st${var.appName}${var.region}${var.environment}")
  resource_group_name      = azurerm_resource_group.resourceGroup.name
  location                 = azurerm_resource_group.resourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
  min_tls_version          = "TLS1_2"
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.appServiceSubnet.id]
    bypass                     = ["AzureServices"]
  }
}

resource "azurerm_storage_container" "storageAccountContainer" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.storageAccount.name
  container_access_type = "private"
}

resource "azurerm_virtual_network" "vNet" {
  name                = "vnet-${local.longName}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "appServiceSubnet" {
  name                 = "appServiceSubnet"
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.vNet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Web", "Microsoft.Storage"]
}

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
  site_config {
    ip_restriction = [
      {
        action                    = "Allow"
        name                      = "AllowVnet"
        priority                  = 1
        virtual_network_subnet_id = azurerm_subnet.appServiceSubnet.id
        ip_address                = null
        headers                   = null
        service_tag               = null
      }
    ]
  }
}