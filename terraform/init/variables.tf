variable "REGION" {
  type = string
}

variable "APPNAME" {
  type = string
}

variable "ENVIRONMENT" {
  type = string
}

variable "WEBAPPTENANTID" {
  type = string
}

variable "ADDRESSSPACE" {
  type = string
}

variable "LOCATION" {
  type = string
}

variable "BLOCKID" {
  type = string
}

variable "CENTRALVIRTUALNETWORKNAME" {
  type = string
}

variable "CENTRALRESOURCEGROUPNAME" {
  type = string  
}

variable "CENTRALADOAGENTADDRESSPREFIX" {
  type = string
}

locals {
  longName  = "${var.APPNAME}-${var.REGION}-${var.ENVIRONMENT}"
  shortName = "${var.APPNAME}${var.REGION}${var.ENVIRONMENT}"
}
