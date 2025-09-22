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
		key                  = "databricks_sandbox/delta_live_tables/sample_scd_pipeline/terraform.tfstate"
  }
}

locals {
  profile = "jeromelieowdatabricks_azure_field-eng-east"
  prefix  = "jlieow"
}

provider "databricks" {
  profile = local.profile
}

resource "databricks_catalog" "_jlieow_dev" {
  name          = "_jlieow_dev"
  comment       = "This catalog is managed by terraform"
  force_destroy = true
}

resource "databricks_schema" "bronze" {
  catalog_name  = databricks_catalog._jlieow_dev.id
  name          = "bronze"
  comment       = "This schema is managed by terraform"
  force_destroy = true
}

data "databricks_current_user" "me" {}

resource "databricks_notebook" "_view_data" {
  content_base64 = filebase64("data/_view_data.sql")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/delta_live_tables/sample_scd_pipeline/_view_data"
  language = "SQL"
}

# Sets up the required resources to run 01_dlt notebook
resource "databricks_notebook" "_00_setup" {
  content_base64 = filebase64("data/00_setup.sql")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/delta_live_tables/sample_scd_pipeline/00_setup"
  language = "SQL"
}

resource "databricks_job" "run_00_setup_sample_scd_pipeline" {

  depends_on = [ 
    databricks_catalog._jlieow_dev, 
    databricks_schema.bronze,
  ]

  name        = "${local.prefix}_job_00_setup_"
  description = "This job runs 00_setup."

  task {
    task_key = "00_setup"

    notebook_task {
      notebook_path = databricks_notebook._00_setup.path
    }
  }
}

resource "null_resource" "run_job_00_setup_sample_scd_pipeline" {

  depends_on = [ 
    databricks_notebook._00_setup
  ]

  triggers = {
    value = filebase64("data/00_setup.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Run job with default settings 
      databricks jobs run-now ${databricks_job.run_00_setup_sample_scd_pipeline.id} --profile ${local.profile}
    EOT
  }
}

resource "databricks_notebook" "_01_dlt" {
  content_base64 = filebase64("data/01_dlt.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/delta_live_tables/sample_scd_pipeline/01_dlt"
  language = "PYTHON"
}

resource "databricks_notebook" "_02_insert_records" {
  content_base64 = filebase64("data/02_insert_records.sql")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/delta_live_tables/sample_scd_pipeline/02_insert_records"
  language = "SQL"
}

resource "databricks_cluster_policy" "policy" {
  name       = "${local.prefix}_cluster_policy"
  definition = jsonencode({
    autotermination_minutes = {
      type   = "fixed"
      value  = 5
      hidden = false
    }
  })
}

resource "databricks_pipeline" "sample_scd_pipeline" {

  depends_on = [ null_resource.run_job_00_setup_sample_scd_pipeline ]

  name             = "${local.prefix}_00_sample_scd_pipeline"
  edition          = "PRO"
  continuous = false
  run_as_user_name = data.databricks_current_user.me.user_name

  library {
    notebook {
      path = databricks_notebook._01_dlt.path
    }
  }

  catalog = databricks_catalog._jlieow_dev.name
  schema  = "etl"

  cluster {
    policy_id    = databricks_cluster_policy.policy.id
    label        = "default"
    node_type_id = "Standard_DS3_v2"
    num_workers  = 1
  }

  photon = false

  channel = "CURRENT"
  development = true

  configuration = {
    "custom.orderStatus": "O,F"
  }
}

resource "null_resource" "populate_volume" {

  depends_on = [ databricks_job.run_00_setup_sample_scd_pipeline ]

  triggers = {
    value = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
    databricks fs cp data/autoloader_1.csv dbfs:/Volumes/_jlieow_dev/etl/landing/files/ --profile ${local.profile}
    EOT
  }
}