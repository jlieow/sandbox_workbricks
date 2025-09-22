# About

Deploy a Databricks AWS Workspace using the Terraform [guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-workspace).

# Authentication

This guide uses a [Databricks admin console](https://accounts.cloud.databricks.com/) Service Principal.

Unfortunately, the Databricks admin console does not support creating Service Principals via the Databricks CLI.

Create a Service Principal in databricks and provide it the `Account admin` role.

Get the following information from the Service Principal:
```
client_id = ""
client_secret = ""
databricks_account_id = ""
```

# Tags

Get the following information from [go/tags](go/tags):
```
tags = {}
```

# Errors

### Error: error configuring Terraform AWS Provider: loading configuration: profile "databricks-sandbox-admin-332745928618" is configured to use SSO but is missing required configuration: sso_region, sso_start_url

Terraform AWS provider version = "~> 4.15.0" likely uses the old version of AWS SDK. In order to overcome the error perform the following:
1. Delete the credential file with `rm ~/.aws/config`.
2. Do not provide a `SSO session name` when running `aws configure sso` as described above.

### Unable to view page

Only the service principal has access to the workspace. 

In order to grant yourself access, first add a Unity Catalog by navigating to `Workspaces > [Workspace] > Configuration > Update Workspace`. Ensure you select a metastore that is in the same region.

Grant yourself access by navigating to `Workspaces > [Workspace] > Permissions > Add Permissions`.