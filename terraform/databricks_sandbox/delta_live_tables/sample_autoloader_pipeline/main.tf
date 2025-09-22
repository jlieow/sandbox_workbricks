terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
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
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/delta_live_tables/dlt_sample_autoloader/_view_data"
  language = "SQL"
}

# Sets up the required resources to run 01_dlt notebook
resource "databricks_notebook" "_00_setup" {
  content_base64 = filebase64("data/00_setup.sql")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/delta_live_tables/dlt_sample_autoloader/00_setup"
  language = "SQL"
}

resource "databricks_job" "run_00_setup" {

  depends_on = [ 
    databricks_catalog._jlieow_dev, 
    databricks_schema.bronze,
  ]

  name        = "${local.prefix}_job_00_setup"
  description = "This job runs 00_setup."

  task {
    task_key = "00_setup"

    notebook_task {
      notebook_path = databricks_notebook._00_setup.path
    }
  }
}

resource "null_resource" "run_job_00_setup" {

  depends_on = [ 
    databricks_notebook._00_setup
  ]

  triggers = {
    value = filebase64("data/00_setup.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Run job with default settings 
      databricks jobs run-now ${databricks_job.run_00_setup.id} --profile ${local.profile}
    EOT
  }
}

resource "databricks_notebook" "_01_dlt" {
  content_base64 = filebase64("data/01_dlt.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/delta_live_tables/dlt_sample_autoloader/01_dlt"
  language = "PYTHON"
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

resource "databricks_pipeline" "dlt_pipeline" {

  depends_on = [ null_resource.run_job_00_setup ]

  provisioner "local-exec" {
    command = <<-EOT
    databricks fs cp data/autoloader_1.csv dbfs:/Volumes/_jlieow_dev/etl/landing/files/ --profile ${local.profile}
    EOT
  }

  name             = "${local.prefix}_pipeline_00_autoloader_sample"
  edition          = "CORE"
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