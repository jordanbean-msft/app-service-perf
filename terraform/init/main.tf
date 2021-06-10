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

data "azurerm_resource_group" "resourceGroup" {
  name = var.RESOURCEGROUPNAME
}

module "init" {
  source        = "./init-module"
  resourceGroup = data.azurerm_resource_group.resourceGroup
  shortName     = local.shortName
  tenantId      = var.WEBAPPTENANTID
}