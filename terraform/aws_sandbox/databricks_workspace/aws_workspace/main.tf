terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    profile      = "databricks-sandbox-admin-332745928618"
    bucket       = "jlieow-tfstate-54321abcde"
    key          = "aws_sandbox/databricks_workspace/aws_workspace/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}

provider "aws" {
  profile = "databricks-sandbox-admin-332745928618"
  region  = var.region
}

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}