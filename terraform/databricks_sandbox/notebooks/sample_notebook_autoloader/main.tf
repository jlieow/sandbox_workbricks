terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

locals {
  profile = "jeromelieowdatabricks_free_edition"
}

provider "databricks" {
  profile = local.profile
}

data "databricks_current_user" "me" {}

resource "databricks_notebook" "autoloader" {
  content_base64 = filebase64("data/autoloader.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebook_sample_autoloader/autoloader"
  language = "PYTHON"
}