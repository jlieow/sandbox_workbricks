variable "client_id" {}
variable "client_secret" {}
variable "databricks_account_id" {}

variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "region" {
  default = "eu-west-2"
}

resource "random_string" "random" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "jlieow-demo${random_string.random.result}"
}