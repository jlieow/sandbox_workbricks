terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  profile = "jeromelieowdatabricks_free_edition"
}

data "databricks_current_user" "me" {}

resource "databricks_notebook" "copy_into" {
  content_base64 = filebase64("data/copy_into.sql")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebook_copy_into_sample/copy_into"
  language = "PYTHON"
}