# Databricks notebook source
# MAGIC %sql
# MAGIC SELECT
# MAGIC   COUNT(event_date) as num_of_logins,
# MAGIC   event_date
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
# MAGIC   event_date
# MAGIC ORDER BY
# MAGIC   event_date DESC
# MAGIC LIMIT 20