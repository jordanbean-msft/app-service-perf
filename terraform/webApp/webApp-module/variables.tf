variable "resourceGroup" {
  type = any
}

variable "shortName" {
  type = string
}

variable "longName" {
  type = string
}

variable "tenantId" {
  type = string
}

variable "keyVault" {
  type = any
}

variable "sqlServerAdminUsername" {
  type      = string
  sensitive = true
}

variable "sqlServerAdminPassword" {
  type      = string
  sensitive = true
}

variable "appName" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "azureAdAdminObjectId" {
  type = string
}

variable "storageAccountContainerImagesName" {
  type = string
}

variable "webAppDomain" {
  type = string
}

variable "webAppClientId" {
  type = string
}