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
		key                  = "databricks_sandbox/notebooks/sample_notebook/terraform.tfstate"
  }
}

locals {
  profile = "jeromelieowdatabricks_free_edition"
}

provider "databricks" {
  profile = local.profile
}

data "databricks_current_user" "me" {}

resource "databricks_notebook" "notebook" {
  content_base64 = base64encode(<<-EOT
    # created from ${abspath(path.module)}
    display(spark.range(10))
    EOT
  )
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebooks/sample_notebook/helloTerraform"
  language = "PYTHON"
}