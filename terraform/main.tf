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
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "resourceGroup" {
  name     = "rg-${local.longName}"
  location = var.LOCATION
}

module "init" {
  source        = "./init-module"
  resourceGroup = azurerm_resource_group.resourceGroup
  shortName     = local.shortName
  tenantId      = var.WEBAPPTENANTID
}

module "webApp" {
  source                            = "./webApp-module"
  resourceGroup                     = azurerm_resource_group.resourceGroup
  shortName                         = local.shortName
  longName                          = local.longName
  keyVault                          = module.init.keyVault
  tenantId                          = var.WEBAPPTENANTID
  appName                           = var.APPNAME
  region                            = var.REGION
  environment                       = var.ENVIRONMENT
  azureAdAdminObjectId              = var.AZUREADADMINOBJECTID
  sqlServerAdminUsername            = var.SQLSERVERADMINUSERNAME
  sqlServerAdminPassword            = var.SQLSERVERADMINPASSWORD
  storageAccountContainerImagesName = var.STORAGEACCOUNTCONTAINERIMAGESNAME
  webAppDomain                      = var.WEBAPPDOMAIN
  webAppClientId                    = var.WEBAPPCLIENTID
}