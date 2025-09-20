# Azure Provider source and version being used
terraform {
required_providers {
	azurerm = {
			source  = "hashicorp/azurerm"
			version = "=4.45.0"
		}
	}

	backend "azurerm" {
		resource_group_name  = "fe-shared-emea-001"
		storage_account_name = "jlieowtfstate54321abcde"
		container_name       = "tfstate"
		key                  = "azure_sandbox/databricks_external_storage/access_connector/terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "3f2e4d32-8e8d-46d6-82bc-5bb8d962328b"
	features {}
}

data "azurerm_resource_group" "fe_shared_emea_001" {
  name = "fe-shared-emea-001"
}

resource "random_string" "random" {
	length 	= 5
	special = false
	upper 	= false
}

locals {
	prefix 		 = "jlieow${random_string.random.result}"
	location   = "West Europe"
}

resource "azurerm_databricks_access_connector" "example_ac" {
  name                = "${local.prefix}-example-ac"
  resource_group_name = data.azurerm_resource_group.fe_shared_emea_001.name
  location            = data.azurerm_resource_group.fe_shared_emea_001.location

  identity {
    type = "SystemAssigned"
  }
}

output "da" {
  value = azurerm_databricks_access_connector.example_ac
}

resource "azurerm_storage_account" "example_sa" {
  name                     = "${local.prefix}examplesa"
  resource_group_name      = data.azurerm_resource_group.fe_shared_emea_001.name
  location                 = data.azurerm_resource_group.fe_shared_emea_001.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_storage_account.example_sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.example_ac.identity[0].principal_id
}