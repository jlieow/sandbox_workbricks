# Azure Provider source and version being used
terraform {
required_providers {
	azurerm = {
			source  = "hashicorp/azurerm"
			version = "=3.0.0"
		}
	}

	backend "azurerm" {
		resource_group_name  = "fe-shared-emea-001"
		storage_account_name = "jlieowtfstate54321abcde"
		container_name       = "tfstate"
		key                  = "azure_sandbox/databricks_workspace/standard_workspace/terraform.tfstate"
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
	prefix = "jlieow"
	# prefix = "${local.identifier}-azure-workspace"
}

resource "azurerm_resource_group" "databricks_managed_rg" {
  name     = "${local.prefix}-databricks-managed-rg"
  location = "West Europe"
}


resource "azurerm_network_security_group" "databricks_nsg" {
  name                = "${local.prefix}-databricks-nsg"
  location            = data.azurerm_resource_group.fe_shared_emea_001.location
  resource_group_name = data.azurerm_resource_group.fe_shared_emea_001.name
}

resource "azurerm_virtual_network" "databricks_vnet" {
  name                = "${local.prefix}-vnet"
  location            = data.azurerm_resource_group.fe_shared_emea_001.location
  resource_group_name = data.azurerm_resource_group.fe_shared_emea_001.name
  address_space       = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "${local.prefix}-public-subnet"
  resource_group_name  = data.azurerm_resource_group.fe_shared_emea_001.name
  virtual_network_name = azurerm_virtual_network.databricks_vnet.name
  address_prefixes     = ["10.0.1.0/25"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "${local.prefix}-private-subnet"
  resource_group_name  = data.azurerm_resource_group.fe_shared_emea_001.name
  virtual_network_name = azurerm_virtual_network.databricks_vnet.name
  address_prefixes     = ["10.0.1.128/25"]
}

# resource "azurerm_databricks_workspace" "workspace" {
#   name                        = "${local.prefix}-workspace"
#   resource_group_name         = data.azurerm_resource_group.fe_shared_emea_001.name
#   managed_resource_group_name = azurerm_resource_group.databricks_managed_rg.name
#   location                    = data.azurerm_resource_group.fe_shared_emea_001.location
#   sku                         = "trial"
	
# 	custom_parameters {
# 		virtual_network_id                                  = azurerm_virtual_network.databricks_vnet.id

#     public_subnet_name                                  = azurerm_subnet.public_subnet.name
#     public_subnet_network_security_group_association_id = azurerm_network_security_group.databricks_nsg.id

#     private_subnet_name                                  = azurerm_subnet.private_subnet.name
#     private_subnet_network_security_group_association_id = azurerm_network_security_group.databricks_nsg.id

#     no_public_ip                                         = true # Required as there is an active policy "DatabricksAzureDBClustersDisablePublicIP" which demands that all Databricks clusters/workspaces are created without a public IP and use only private networking.
# 	}
# }

# resource "azurerm_storage_account" "databricks_storage_account" {
#   name                     = "${local.prefix}databrickssa"
#   resource_group_name      = data.azurerm_resource_group.fe_shared_emea_001.name
#   location                 = data.azurerm_resource_group.fe_shared_emea_001.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"

#   is_hns_enabled = true
# }

# resource "azurerm_storage_container" "databricks_storage_account_container_source" {
#   name                  = "${local.prefix}-source"
#   storage_account_name    = azurerm_storage_account.databricks_storage_account.name
#   container_access_type = "private"
# }

# resource "azurerm_storage_container" "databricks_storage_account_container_destination" {
#   name                  = "${local.prefix}-destination"
#   storage_account_name    = azurerm_storage_account.databricks_storage_account.name
#   container_access_type = "private"
# }