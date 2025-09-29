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
  host = "https://accounts.azuredatabricks.net"
  account_id = "ccb842e7-2376-4152-b0b0-29fa952379b8"
  azure_tenant_id = "bf465dc7-3bc8-4944-b018-092572b5c20d" # Required when the backend is using a different tenant
}

resource "databricks_group" "jlieow_group" {
  display_name = "jlieow_group"
}

resource "databricks_service_principal" "jlieow_admin_sp" {
  display_name = "jlieow_admin_sp"
}
