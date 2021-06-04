variable "location" {
  type = string
}

variable "region" {
  type = string
}

variable "appName" {
  type = string
}

variable "environment" {
  type = string
}

variable "sqlServerAdminUsername" {
  type      = string
  sensitive = true
}

variable "sqlServerAdminPassword" {
  type      = string
  sensitive = true
}

variable "azureAdAdminObjectId" {
  type      = string
  sensitive = true
}

variable "webAppClientId" {
  type      = string
  sensitive = true
}

variable "webAppDomain" {
  type      = string
  sensitive = true
}

variable "webAppTenantId" {
  type      = string
  sensitive = true
}

locals {
  longName = "${var.appName}-${var.region}-${var.environment}"
}
