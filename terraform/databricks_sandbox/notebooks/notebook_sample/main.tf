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

resource "databricks_notebook" "notebook" {
  content_base64 = base64encode(<<-EOT
    # created from ${abspath(path.module)}
    display(spark.range(10))
    EOT
  )
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/notebook_sample/helloTerraform"
  language = "PYTHON"
}