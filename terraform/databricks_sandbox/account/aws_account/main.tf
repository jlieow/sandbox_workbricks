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
		key                  = "databricks_sandbox/account/aws_account/terraform.tfstate"
  }
}

provider "databricks" {
  host = "https://accounts.cloud.databricks.com"
  account_id = "0d26daa6-5e44-4c97-a497-ef015f91254a"
}

resource "databricks_group" "jlieow_group" {
  display_name = "jlieow_group"
}

resource "databricks_service_principal" "jlieow_admin_sp" {
  display_name = "jlieow_admin_sp"
}
