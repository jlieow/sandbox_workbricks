# Databricks notebook source
# MAGIC %sql
# MAGIC SELECT
# MAGIC   COUNT(DISTINCT run_id) as job_count,
# MAGIC   to_date(period_start_time) as date
# MAGIC FROM system.lakeflow.job_run_timeline
# MAGIC WHERE
# MAGIC   period_start_time > CURRENT_TIMESTAMP() - INTERVAL 6 MONTHS
# MAGIC GROUP BY ALL
# MAGIC ORDER BY
# MAGIC   date

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT
# MAGIC   COUNT(DISTINCT run_id) as job_count
# MAGIC FROM system.lakeflow.job_run_timeline
# MAGIC WHERE
# MAGIC   period_start_time > CURRENT_TIMESTAMP() - INTERVAL 6 MONTHS