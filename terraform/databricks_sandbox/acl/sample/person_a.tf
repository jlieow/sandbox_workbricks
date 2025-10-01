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
		key                  = "databricks_sandbox/acl/sample/terraform.tfstate"
  }
}

locals {
  profile = "jeromelieowdatabricks_azure_field-eng-east"
  prefix  = "jlieow"
}

resource "random_string" "random" {
	length 	= 5
	special = false
	upper 	= false
}

provider "databricks" {
  profile = local.profile
}

resource "databricks_group" "eng" {
  display_name = "${local.prefix}-eng"
}

resource "databricks_service_principal" "person_a" {
  display_name = "${local.prefix}-sp-person_a"
}

resource "databricks_service_principal_secret" "person_a_secret" {
  service_principal_id = databricks_service_principal.person_a.id
}

resource "databricks_group_member" "vip_member" {
  group_id  = databricks_group.eng.id
  member_id = databricks_service_principal.person_a.id
}

resource "databricks_sql_endpoint" "warehouse" {
  name             = "${local.prefix}-warehouse"
  cluster_size     = "Small"
  max_num_clusters = 1
}

# 1. Can use and run queries on at least one SQL warehouse.
resource "databricks_permissions" "endpoint_usage" {
  sql_endpoint_id = databricks_sql_endpoint.warehouse.id

  access_control {
    group_name       = databricks_group.eng.display_name
    permission_level = "CAN_USE"
  }
}

# 2. Can create “classic” clusters in dedicated mode and with the maximum number of workers set to 3.

data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "cluster" {
  cluster_name            = "${local.prefix}-cluster"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 0
  autoscale {
    min_workers = 1
    max_workers = 3
  }

  kind = "CLASSIC_PREVIEW"
  data_security_mode = "DATA_SECURITY_MODE_DEDICATED"
}

resource "databricks_permissions" "cluster_usage" {
  cluster_id = databricks_cluster.cluster.id

  access_control {
    group_name       = databricks_group.eng.display_name
    permission_level = "CAN_RESTART"
  }
}

resource "databricks_cluster_policy" "policy" {
  name = "${local.prefix}-policy"
  definition = jsonencode({
    "autotermination_minutes": {
      "type": "fixed",
      "value": 0
    },
    "data_security_mode": {
      "type": "fixed",
      "value": "DATA_SECURITY_MODE_DEDICATED"
    },
    "autoscale.min_workers": {
      "type": "range",
      "defaultValue": 1,
      "minValue": 1,
      "maxValue": 3
    },
    "autoscale.max_workers": {
      "type": "fixed",
      "value": 3
    }
  })
}

resource "databricks_permissions" "policy_usage" {
  cluster_policy_id = databricks_cluster_policy.policy.id

  access_control {
    group_name       = databricks_group.eng.display_name
    permission_level = "CAN_USE"
  }
}

# 3. They have a group workspace folder to collaborate with others, and have the ability to read and write files in it.

resource "databricks_directory" "this" {
  path = "/${local.prefix}_directory/test"
}

resource "databricks_permissions" "folder_usage_by_path" {
  directory_path = databricks_directory.this.path

  access_control {
    group_name       = databricks_group.eng.display_name
    permission_level = "CAN_EDIT"
  }
}

# 4. They can use their team's sandbox catalog that they can create new schemas, tables, and other objects in - however they can’t delete the catalog.
resource "databricks_catalog" "_jlieow_dev" {
  name          = "_jlieow_dev_${random_string.random.result}"
  comment       = "This catalog is managed by terraform"
  force_destroy = true
}

resource "databricks_schema" "bronze" {
  catalog_name  = databricks_catalog._jlieow_dev.id
  name          = "bronze"
  comment       = "This schema is managed by terraform"
  force_destroy = true
}

resource "databricks_grants" "sandbox" {
  
  catalog = databricks_catalog._jlieow_dev.name

  grant {
    principal  = databricks_service_principal.person_a.application_id
    privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "CREATE_VOLUME", "CREATE_MODEL", "CREATE_FUNCTION", "CREATE_MATERIALIZED_VIEW", "MODIFY"] 
  }
}

# 5. They can create and run jobs. 

resource "databricks_job" "this" {
  name                = "Featurization"
  max_concurrent_runs = 1

  task {
    task_key = "task1"

    new_cluster {
      num_workers   = 300
      spark_version = data.databricks_spark_version.latest_lts.id
      node_type_id  = data.databricks_node_type.smallest.id
    }

    notebook_task {
      notebook_path = "/${local.prefix}_directory/test"
    }
  }
}

resource "databricks_permissions" "job_usage" {
  job_id = databricks_job.this.id

  access_control {
    group_name       = databricks_group.eng.display_name
    permission_level = "CAN_MANAGE"
  }
}

# 6. They can use serverless compute with a budget policy that has a single tag with key t_costcenter and value of groupa.
# Also known as serverless budget policy, this is still in public preview and there is no terraform resource block available for this object as of 1 Oct 2025
# In order to create a serverless budget policy, navigate to Settings > Compute > Serverless usage policies > Manage > Create