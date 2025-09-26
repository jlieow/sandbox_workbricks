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
		key                  = "databricks_sandbox/logfood-master/queries/terraform.tfstate"
  }
}

locals {
  profile = "jeromelieowdatabricks_logfood-master"
}

provider "databricks" {
  profile = local.profile
}

data "databricks_current_user" "me" {}

locals {
  workflow_files = fileset("data/Logfood Example Queries", "*.sql")

  workflows = tomap({
    for fn in local.workflow_files :
    substr(fn, 0, length(fn)-5) => "${path.module}/workflows/${fn}"
  })
}

output "workflow_files" {
  value = local.workflow_files
}

output "workflows" {
  value = local.workflows
}

resource "databricks_notebook" "notebook" {
  
  for_each = fileset("data/logfood_example_queries", "*.sql")

  content_base64 = filebase64("data/logfood_example_queries/${each.value}")
  path     = "${data.databricks_current_user.me.home}/logfood_example_queries/${each.value}"
  language = "SQL"
}