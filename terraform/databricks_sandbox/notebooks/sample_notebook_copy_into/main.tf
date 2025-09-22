terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }

  backend "azurerm" {
		resource_group_name  = "fe-shared-emea-001"
		storage_account_name = "jlieowtfstate54321abcde"
		container_name       = "tfstate"
		key                  = "databricks_sandbox/notebooks/sample_notebook_copy_into/terraform.tfstate"
  }
}

locals {
  profile = "jeromelieowdatabricks_free_edition"
}

provider "databricks" {
  profile = local.profile
}

data "databricks_current_user" "me" {}

resource "databricks_notebook" "copy_into" {
  content_base64 = filebase64("data/copy_into.sql")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebooks/sample_notebook_copy_into/copy_into"
  language = "SQL"
}