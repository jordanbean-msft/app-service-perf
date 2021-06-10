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

variable "RESOURCEGROUPNAME" {
  type = string
}

locals {
  longName  = "${var.APPNAME}-${var.REGION}-${var.ENVIRONMENT}"
  shortName = "${var.APPNAME}${var.REGION}${var.ENVIRONMENT}"
}
