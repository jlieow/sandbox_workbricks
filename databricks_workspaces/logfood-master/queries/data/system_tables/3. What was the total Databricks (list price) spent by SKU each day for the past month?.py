# Databricks notebook source
# MAGIC %sql
# MAGIC SELECT
# MAGIC   sku_name,
# MAGIC   pricing
# MAGIC FROM
# MAGIC   system.billing.list_prices
# MAGIC LIMIT 20

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT
# MAGIC   sku_name,
# MAGIC   usage_date,
# MAGIC   usage_quantity
# MAGIC FROM
# MAGIC   system.billing.usage
# MAGIC LIMIT 20

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT
# MAGIC   usage.usage_date,
# MAGIC   usage.sku_name,
# MAGIC   usage.usage_quantity * list_prices.pricing.effective_list.default AS total_list_price_spend
# MAGIC FROM system.billing.usage AS usage
# MAGIC JOIN system.billing.list_prices AS list_prices
# MAGIC   ON usage.sku_name = list_prices.sku_name
# MAGIC WHERE
# MAGIC   usage.sku_name = "ENTERPRISE_ALL_PURPOSE_COMPUTE" AND
# MAGIC   usage.usage_date = "2025-10-01"
# MAGIC LIMIT 50

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT
# MAGIC     usage.usage_date,
# MAGIC     usage.sku_name,
# MAGIC     SUM(usage.usage_quantity * list_prices.pricing.effective_list.default) AS total_list_price_spend
# MAGIC FROM system.billing.usage AS usage
# MAGIC JOIN system.billing.list_prices AS list_prices
# MAGIC   ON usage.sku_name = list_prices.sku_name
# MAGIC WHERE
# MAGIC     usage.usage_date BETWEEN DATE_ADD(CURRENT_DATE(), -30) AND CURRENT_DATE() -- Adjust for "past month" as needed
# MAGIC GROUP BY
# MAGIC     usage.usage_date,
# MAGIC     usage.sku_name
# MAGIC ORDER BY
# MAGIC     usage.usage_date,
# MAGIC     usage.sku_name;