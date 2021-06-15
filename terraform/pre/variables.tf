variable "REGION" {
  type = string
}

variable "APPNAME" {
  type = string
}

variable "ENVIRONMENT" {
  type = string
}

variable "LOCATION" {
  type = string
}

variable "ADDRESSSPACE" {
  type = string
}

variable "ADOAGENTADDRESSPREFIX" {
  type = string
}

variable "AZPURL" {
  type = string
}

variable "AZPPOOL" {
  type = string
}

variable "AZPTOKEN" {
  type = string
}

locals {
  longName  = "${var.APPNAME}-${var.REGION}-${var.ENVIRONMENT}"
  shortName = "${var.APPNAME}${var.REGION}${var.ENVIRONMENT}"
}
