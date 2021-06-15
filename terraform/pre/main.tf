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
    key                  = "pre.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

module "pre" {
  source        = "./pre-module"
  longName      = local.longName
  shortName      = local.shortName
  location      = var.LOCATION
  addressSpace  = var.ADDRESSSPACE
  adoAgentAddressPrefix = var.ADOAGENTADDRESSPREFIX
  appName = var.APPNAME
  environment = var.ENVIRONMENT
}
