terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  profile = "jeromelieowdatabricks_free_edition"
}

data "databricks_current_user" "me" {}

# get the day of the week
resource "databricks_notebook" "_01_get_run_day" {
  content_base64 = filebase64("data/01_get_run_day.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/job_sample/01_get_run_day"
  language = "PYTHON"
}

# write_emp_data filters based on a provided parameter and returns a count of the records
resource "databricks_notebook" "_02_write_emp_data" {
  content_base64 = filebase64("data/02_write_emp_data.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/job_sample/02_write_emp_data"
  language = "PYTHON"
}

resource "databricks_notebook" "_03_else_condition" {
  content_base64 = filebase64("data/03_else_condition.py")
  path     = "${data.databricks_current_user.me.home}/terraform_notebooks/job_sample/03_else_condition"
  language = "PYTHON"
}

resource "databricks_job" "process_emp_data_by_dept" {
  name        = "Example Job - process_emp_data_by_dept"
  description = "This job executes multiple notebooks."

  task {
    task_key = "01_set_day"

    notebook_task {
      notebook_path = databricks_notebook._01_get_run_day.path

      base_parameters = {
        input_date = "{{job.start_time.iso_datetime}}"
      }
    }
  }

  task {
    task_key = "check_day"

    depends_on {
      task_key = "01_set_day"
    }

    condition_task {
      left  = "{{tasks.01_set_day.values.input_day}}"
      op    = "EQUAL_TO"
      right = "Sun"
    }
  }

  task {
    task_key = "02_process_data"

    depends_on {
      task_key = "check_day"
      outcome  = true
    }

    notebook_task {
      notebook_path = databricks_notebook._02_write_emp_data.path

      base_parameters = {
        dept = "sales"
      }
    }
  }

  task {
    task_key = "03_else_condition"

    depends_on {
      task_key = "check_day"
      outcome  = false
    }

    notebook_task {
      notebook_path = databricks_notebook._03_else_condition.path
    }
  }
}

resource "databricks_job" "process_emp_data_by_dept_with_iterative_task" {
  name        = "Example Job - process_emp_data_by_dept_with_iterative_task"
  description = "This job executes multiple notebooks."

  task {
    task_key = "01_set_day"

    notebook_task {
      notebook_path = databricks_notebook._01_get_run_day.path

      base_parameters = {
        input_date = "{{job.start_time.iso_datetime}}"
      }
    }
  }

  task {
    task_key = "check_day"

    depends_on {
      task_key = "01_set_day"
    }

    condition_task {
      left  = "{{tasks.01_set_day.values.input_day}}"
      op    = "EQUAL_TO"
      right = "Sun"
    }
  }

  task {
    task_key = "02_process_data"

    depends_on {
      task_key = "check_day"
      outcome  = true
    }

    for_each_task {
      inputs = "[ \"sales\", \"office\" ]"
      task {
        task_key = "02_process_data_iteration"
        notebook_task {
          notebook_path = databricks_notebook._02_write_emp_data.path

          base_parameters = {
            dept = "{{input}}"
          }
        }
      }
    }
  }

  task {
    task_key = "03_else_condition"

    depends_on {
      task_key = "check_day"
      outcome  = false
    }

    notebook_task {
      notebook_path = databricks_notebook._03_else_condition.path
    }
  }
}

resource "null_resource" "trigger_job" {

  depends_on = [ 
    databricks_job.process_emp_data_by_dept,
    databricks_job.process_emp_data_by_dept_with_iterative_task
  ]

  triggers = {
    value = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Run job with default settings 
      databricks jobs run-now ${databricks_job.process_emp_data_by_dept.id} --profile jeromelieowdatabricks_free_edition
      databricks jobs run-now ${databricks_job.process_emp_data_by_dept_with_iterative_task.id} --profile jeromelieowdatabricks_free_edition

      # Run job with different settings 
      databricks jobs run-now --json '{ "job_id":${databricks_job.process_emp_data_by_dept.id}, "notebook_params": { "dept":"sales", "input_date":"2024-10-27T13:00:00" } }' --profile jeromelieowdatabricks_free_edition
      databricks jobs run-now --json '{ "job_id":${databricks_job.process_emp_data_by_dept_with_iterative_task.id}, "notebook_params": { "input_date":"2024-10-27T13:00:00" } }' --profile jeromelieowdatabricks_free_edition
    EOT
  }
}