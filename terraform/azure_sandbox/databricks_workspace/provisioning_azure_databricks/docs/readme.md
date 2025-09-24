# About

Deploy a Databricks Azure Workspace using the Terraform [guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/azure-workspace).

# Authentication

Since Databricks is a first party service on Azure, only the Azure provider is required. Ensure you have selected the correct Azure subscription and tenant by using `az login --output table` and choosing from the menu.

# Tags

Get the following information from [go/tags](go/tags):
```
tags = {}
```

# Errors

### Unable to view page

Only the entity used to create the workspace has access to the workspace. 

In order to grant yourself access, first add a Unity Catalog by navigating to `Workspaces > [Workspace] > Configuration > Update Workspace`. Ensure you select a metastore that is in the same region.

Grant yourself access by navigating to `Workspaces > [Workspace] > Permissions > Add Permissions`.