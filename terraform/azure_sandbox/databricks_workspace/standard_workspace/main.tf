# Azure Provider source and version being used
terraform {
required_providers {
	azurerm = {
			source  = "hashicorp/azurerm"
			version = "=3.0.0"
		}
	}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
	features {}
}

data "azurerm_resource_group" "fe_shared_emea_001" {
  name = "fe-shared-emea-001"
}

locals {
	identifier = "jlieow"
	prefix = "${local.identifier}-sample-workspace"
}

resource "azurerm_databricks_workspace" "sample_workspace" {
  name                = "${local.prefix}"
  resource_group_name = data.azurerm_resource_group.fe_shared_emea_001.name
  location            = data.azurerm_resource_group.fe_shared_emea_001.location
  sku                 = "standard"
	
	custom_parameters {
		no_public_ip = true # Required as there is an active policy "DatabricksAzureDBClustersDisablePublicIP" which demands that all Databricks clusters/workspaces are created without a public IP and use only private networking.
	}

  # tags = {
  #   Environment = "Production"
  # }
}