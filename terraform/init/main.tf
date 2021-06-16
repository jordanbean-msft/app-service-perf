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
    key                  = "init.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

module "init" {
  source                       = "./init-module"
  longName                     = local.longName
  shortName                    = local.shortName
  tenantId                     = var.WEBAPPTENANTID
  addressSpace                 = var.ADDRESSSPACE
  location                     = var.LOCATION
  blockId                      = var.BLOCKID
  centralVirtualNetworkName    = var.CENTRALVIRTUALNETWORKNAME
  centralResourceGroupName     = var.CENTRALRESOURCEGROUPNAME
  environment                  = var.ENVIRONMENT
  centralAdoAgentAddressPrefix = var.CENTRALADOAGENTADDRESSPREFIX
}