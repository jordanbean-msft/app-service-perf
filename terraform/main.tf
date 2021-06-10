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