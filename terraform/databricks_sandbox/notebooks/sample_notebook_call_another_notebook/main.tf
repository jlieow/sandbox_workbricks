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

# Notebook provides a parameter and calls write_emp_data
resource "databricks_notebook" "run_write_emp_data" {
  content_base64 = filebase64("data/run_write_emp_data.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebooks/sample_notebook_call_another_notebook/run_write_emp_data"
  language = "PYTHON"
}

# write_emp_data filters based on a provided parameter and returns a count of the records
resource "databricks_notebook" "write_emp_data" {
  content_base64 = filebase64("data/write_emp_data.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebooks/sample_notebook_call_another_notebook/write_emp_data"
  language = "PYTHON"
}