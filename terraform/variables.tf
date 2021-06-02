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

locals {
  longName = "${var.appName}-${var.region}-${var.environment}"
}
