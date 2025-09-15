# Configure Access

Use `az login`.

# Configure Remote State Storage Account

Create a Azure storage account and container:
```
RESOURCE_GROUP_NAME=fe-shared-emea-001
STORAGE_ACCOUNT_NAME=jlieowtfstate54321abcde
CONTAINER_NAME=tfstate

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
```

Create a Terraform configuration with a backend configuration block.
```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
      resource_group_name  = "fe-shared-emea-001"
      storage_account_name = "jlieowtfstate54321abcde"
      container_name       = "tfstate"
      key                  = "azure_sandbox/xxx/yyy/terraform.tfstate"
  }
}
```