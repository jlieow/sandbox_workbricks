# Databricks notebook source
# DLT works with three types of Datasets
# Streaming Tables (Permanent/Temporary) - Used as Append Data Sources, Incremental data
# Materialized Views - Used for transformations, aggregations or computations
# Views - Used for intermediate Tranformations, not stored in Target Schema

import dlt

# COMMAND ----------

# Create a Streaming Table for Orders
# Input for Stream Table is a streaming source
@dlt.table(
  table_properties = {"quality": "bronze"},
  comment = "Order bronze table"
)
def orders_bronze():
  df = spark.readStream.table("_jlieow_dev.bronze.orders_raw")
  return df

# COMMAND ----------

# Create a streaming table for Orders Autoloader
@dlt.table(
  table_properties = {"quality": "bronze"},
  comment = "Order Autoloader",
  name = "orders_autoloader_bronze"
)
def func():
  df = (
    spark
    .readStream
    .format("cloudFiles")
    .option("cloudFiles.schemaHints", "o_orderkey long, o_custkey long, o_orderstatus string, o_totalprice decimal(18,2),o_orderdate date, o_orderpriority string, o_clerk string, o_shippriority integer, o_comment string")
    .option("cloudFiles.schemaLocation", "/Volumes/_jlieow_dev/etl/landing/autoloader/schemas/1/") # Where Autoloader saves the schema
    .option("cloudFiles.format", "CSV") # File format of files in Streaming Source
    .option("pathGlobfilter", "*.csv")
    .option("cloudFiles.schemaEvolutionMode", "none") # Does not evolve the schema, new columns are ignored, and data is not rescued unless the rescuedDataColumn option is set. Stream does not fail due to schema changes.
    .load("/Volumes/_jlieow_dev/etl/landing/files/")  # Streaming Source
  )

  return df

# COMMAND ----------

# Append Flow UNIONs multiple streaming tables incrementally
dlt.create_streaming_table("orders_union_bronze")

# Append Flow
@dlt.append_flow(
  target = "orders_union_bronze"
)
def order_delta_append():
  df = spark.readStream.table("LIVE.orders_bronze")
  return df

# Append Flow
@dlt.append_flow(
  target = "orders_union_bronze"
)
def order_autoloader_append() :
  df = spark.readStream.table("LIVE.orders_autoloader_bronze")
  return df

# COMMAND ----------

# Create a Materialized View for Customers
# Input for Materialized View is a batch source
# @dlt. table(
#   table_properties = {"quality": "bronze"},
#   comment = "Customer bronze table",
#   name = "customer_bronze" # If name is specified in the decorator, tables/views take this name instead of the function name.
# )
# def cust_bronze():
#   df = spark.read.table("_jlieow_dev.bronze.customer_raw")
#   return df

# COMMAND ----------

# Create a Materialized View for Customers
@dlt.view(
  comment = "Customer bronze view"
)
def customer_bronze_vw() :
  df = spark.readStream.table("_jlieow_dev.bronze.customer_raw")
  return df

# COMMAND ----------

# SCD Type 1 simply overwrites old data with new data, so only the most current value is retained and no history is kept. 
from pyspark.sql.functions import expr

dlt.create_streaming_table("customer_scd1_bronze")

# SCD 1 Customer
dlt.apply_changes(
  target             = "customer_scd1_bronze",
  source             = "customer_bronze_vw", # In order to use apply_changes to create a SCD table, a streaming table/view source is required
  keys               = ["c_custkey"],
  stored_as_scd_type = 1,
  apply_as_deletes   = expr("_src_action = 'D'"),
  apply_as_truncates = expr("_src_action = 'T'"),
  sequence_by        = "_src_insert_dt",
)

# The AUTO CDC APIs replace the APPLY CHANGES APIs and are recommended - https://docs.databricks.com/aws/en/dlt/cdc
# dlt.create_auto_cdc_flow(
#   target             = "customer_scd1_bronze",
#   source             = "customer_bronze_vw", # In order to use apply_changes to create a SCD table, a streaming table/view source is required
#   keys               = ["c_custkey"],
#   stored_as_scd_type = 1,
#   apply_as_deletes   = expr("_src_action = 'D'"),
#   apply_as_truncates = expr("_src_action = 'T'"),
#   sequence_by        = "_src_insert_dt",
# )

# COMMAND ----------

# SCD Type 2 adds a new row to the dimension table each time a change occurs, preserving historical versions and enabling the tracking of changes over time.
from pyspark.sql.functions import expr

dlt.create_streaming_table("customer_scd2_bronze")

# SCD 2 Customer
dlt.apply_changes(
  target             = "customer_scd2_bronze",
  source             = "customer_bronze_vw", # In order to use apply_changes to create a SCD table, a streaming table/view source is required
  keys               = ["c_custkey"],
  stored_as_scd_type = 2,
  except_column_list = ["_src_action", "_src_insert_dt"],
  sequence_by        = "_src_insert_dt",
)

# The AUTO CDC APIs replace the APPLY CHANGES APIs and are recommended - https://docs.databricks.com/aws/en/dlt/cdc
# dlt.create_auto_cdc_flow(
#   target             = "customer_scd2_bronze",
#   source             = "customer_bronze_vw", # In order to use apply_changes to create a SCD table, a streaming table/view source is required
#   keys               = ["c_custkey"],
#   stored_as_scd_type = 2,
#   except_column_list = ["_src_action", "_src_insert_dt"],
#   sequence_by        = "_src_insert_dt",
# )

# COMMAND ----------

# Create a View to join Orders with Customers
@dlt.view(
  comment = "Joined View"
)
def joined_vw():
  df_o = spark.read.table("LIVE.orders_union_bronze")
  df_c = spark.read.table("LIVE.customer_scd2_bronze").where("__END_AT is null")
  
  df_join = df_o.join(df_c, how = "left_outer", on=df_c.c_custkey==df_o.o_custkey)
  
  return df_join

# COMMAND ----------

# Create MV to add new column
from pyspark.sql.functions import current_timestamp

@dlt. table(
  table_properties = {"quality": "silver"},
  comment = "Joined table",
  name = "joined_silver"
)
def joined_silver():
  df = spark.read.table("LIVE.joined_vw").withColumn("__insert_date", current_timestamp())
  return df

# COMMAND ----------

# Aggregate based on c_mktsegment and find the count of order (c_orderkey)
from pyspark.sql.functions import count, sum

@dlt. table(
  table_properties = {"quality": "gold"},
  comment = "orders aggregated table"
)
def orders_agg_gold():
  df = spark.read.table("LIVE.joined_silver")

  df_final = df.groupBy("c_mktsegment").agg(count("o_orderkey").alias("count_orders"), sum("o_totalprice").alias("sum_totalprice")).withColumn("__insert_date", current_timestamp())

  return df_final

# COMMAND ----------

# Retrieves the configuration parameters
_order_status = spark.conf.get("custom.orderstatus", "NA")

for _status in _order_status.split(","):
  @dlt. table(
    table_properties = {"quality": "gold"},
    comment = "orders aggregated table",
    name = f"orders_agg_{_status}_gold"
  )
  def func():
    df = spark.read.table("LIVE.joined_silver")

    df_final = df.where(f"o_orderstatus = '{_status}'").groupBy("c_mktsegment").agg(count("o_orderkey").alias("count_orders"),sum("o_totalprice").alias("sum_totalprice")).withColumn("__insert_date", current_timestamp())

    return df_final