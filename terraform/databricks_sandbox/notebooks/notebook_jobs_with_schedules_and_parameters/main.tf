terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  profile = "DEFAULT"
}

data "databricks_current_user" "me" {}

resource "databricks_notebook" "run_write_emp_data" {
  content_base64 = filebase64("data/Run_Write_Emp_Data.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebook_jobs_with_schedules_and_parameters/run_write_emp_data"
  language = "PYTHON"
}

resource "databricks_notebook" "write_emp_data" {
  content_base64 = filebase64("data/Write_Emp_Data.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebook_jobs_with_schedules_and_parameters/write_emp_data"
  language = "PYTHON"
}