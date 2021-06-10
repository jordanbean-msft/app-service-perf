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
  type = string
}

variable "webAppClientId" {
  type = string
}

variable "webAppDomain" {
  type = string
}

variable "webAppTenantId" {
  type = string
}

variable "webAppClientSecret" {
  type      = string
  sensitive = true
}

variable "pipelineObjectId" {
  type = string
}

locals {
  longName  = "${var.appName}-${var.region}-${var.environment}"
  shortName = "${var.appName}${var.region}${var.environment}"
}
