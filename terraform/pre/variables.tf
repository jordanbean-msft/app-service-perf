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

locals {
  longName  = "${var.APPNAME}-${var.REGION}-${var.ENVIRONMENT}"
  shortName = "${var.APPNAME}${var.REGION}${var.ENVIRONMENT}"
}
