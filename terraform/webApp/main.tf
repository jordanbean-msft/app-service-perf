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
    container_name       = "appserviceperf"
    key                  = "webApp.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "keyVault" {
  name                = var.KEYVAULTNAME
  resource_group_name = var.RESOURCEGROUPNAME
}

data "azurerm_resource_group" "resourceGroup" {
  name = var.RESOURCEGROUPNAME
}

module "webApp" {
  source                            = "./webApp-module"
  resourceGroup                     = data.azurerm_resource_group.resourceGroup
  shortName                         = local.shortName
  longName                          = local.longName
  keyVault                          = data.azurerm_key_vault.keyVault
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
  vNetName                          = var.VNETNAME
  appServiceSubnetName              = var.APPSERVICESUBNETNAME
  centralvNetName                   = var.CENTRALVNETNAME
  adoAgentSubnetName                = var.ADOAGENTSUBNETNAME
  centralResourceGroupName          = var.CENTRALRESOURCEGROUPNAME
}