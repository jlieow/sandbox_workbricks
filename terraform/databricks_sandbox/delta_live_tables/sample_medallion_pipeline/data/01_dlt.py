# Databricks notebook source
# DLT works with three types of Datasets
# Streaming Tables (Permanent/Temporary) - Used as Append Data Sources, Incremental data
# Materialized Views - Used for transformations, aggregations or computations
# Views - Used for intermediate Tranformations, not stored in Target Schema

import dlt

# COMMAND ----------

# Create a Streaming Table for orders
# Input for Stream Table is a streaming source
@dlt.table(
  table_properties = {"quality": "bronze"},
  comment = "Order bronze table"
)
def orders_bronze():
  df = spark.readStream.table("_jlieow_dev.bronze.orders_raw")
  return df

# COMMAND ----------

# Create a Materialized View for customers
# Input for Materialized View is a batch source
@dlt. table(
  table_properties = {"quality": "bronze"},
  comment = "Customer bronze table",
  name = "customer_bronze" # If name is specified in the decorator, tables/views take this name instead of the function name.
)
def cust_bronze():
  df = spark.read.table("_jlieow_dev.bronze.customer_raw")
  return df

# COMMAND ----------

# Create a View to join orders with customers
@dlt.view(
  comment = "Joined View"
)
def joined_vw():
  df_o = spark.read.table("LIVE.orders_bronze")
  df_c = spark.read.table("LIVE.customer_bronze")
  
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
from pyspark.sql.functions import count

@dlt. table(
  table_properties = {"quality": "gold"},
  comment = "orders aggregated table"
)
def orders_agg_gold():
  df = spark.read.table("LIVE.joined_silver")

  df_final = df.groupBy("c_mktsegment").agg(count("o_orderkey").alias("sum_orders")).withColumn("__insert_date", 
  current_timestamp())

  return df_final