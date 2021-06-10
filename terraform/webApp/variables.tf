variable "LOCATION" {
  type = string
}

variable "REGION" {
  type = string
}

variable "APPNAME" {
  type = string
}

variable "ENVIRONMENT" {
  type = string
}

variable "SQLSERVERADMINUSERNAME" {
  type      = string
  sensitive = true
}

variable "SQLSERVERADMINPASSWORD" {
  type      = string
  sensitive = true
}

variable "AZUREADADMINOBJECTID" {
  type = string
}

variable "WEBAPPCLIENTID" {
  type = string
}

variable "WEBAPPDOMAIN" {
  type = string
}

variable "WEBAPPTENANTID" {
  type = string
}

variable "WEBAPPCLIENTSECRET" {
  type      = string
  sensitive = true
}

variable "PIPELINEOBJECTID" {
  type = string
}

variable "STORAGEACCOUNTCONTAINERIMAGESNAME" {
  type = string
}

variable "RESOURCEGROUPNAME" {
  type = string
}

variable "KEYVAULTNAME" {
  type = string
}

locals {
  longName  = "${var.APPNAME}-${var.REGION}-${var.ENVIRONMENT}"
  shortName = "${var.APPNAME}${var.REGION}${var.ENVIRONMENT}"
}
