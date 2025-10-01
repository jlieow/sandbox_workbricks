# Databricks notebook source
# MAGIC %sql
# MAGIC SELECT
# MAGIC   COUNT(*) as num_of_logins,
# MAGIC   DATE_FORMAT(event_date, 'yyyy-MM') AS year_month
# MAGIC FROM
# MAGIC   system.access.audit
# MAGIC WHERE
# MAGIC   action_name IN (
# MAGIC     'samlLogin',
# MAGIC     'oidcBrowserLogin',
# MAGIC     'tokenLogin'
# MAGIC   ) AND
# MAGIC   REGEXP_LIKE(user_identity.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
# MAGIC --   -- AND user_type = 'human'
# MAGIC GROUP BY
# MAGIC   year_month
# MAGIC ORDER BY
# MAGIC   year_month DESC
# MAGIC LIMIT 20