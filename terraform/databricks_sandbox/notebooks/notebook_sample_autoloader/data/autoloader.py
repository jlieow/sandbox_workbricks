# Databricks notebook source
# MAGIC %md
# MAGIC Auto Loader incrementally and efficiently processes new data files as they arrive in cloud storage. It provides a Structured Streaming source called cloudFiles. Given an input directory path on the cloud file storage, the cloudFiles source automatically processes new files as they arrive, with the option of also processing existing files in that directory.
# MAGIC
# MAGIC Supports data ingestion in both streaming and batch modes with exactly-once processing, and can seamlessly scale to handle [billions of files](https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/#how-does-auto-loader-work) per hour.

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Cleans up dangling resources to ensure idempotency
# MAGIC DROP TABLE IF EXISTS dev.bronze.invoice_al_1

# COMMAND ----------

# Cleans up dangling resources to ensure idempotency
dbutils.fs.rm("/Volumes/dev/bronze/landing/autoloader_input", True)
dbutils.fs.rm("/Volumes/dev/bronze/landing/checkpoint", True)

# COMMAND ----------

# Create autoloader_input folder in Volume
dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/autoloader_input/2010/12/01") 
dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/autoloader_input/2010/12/02") 
dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/autoloader_input/2010/12/03") 
dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/autoloader_input/2010/12/04") 
dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/autoloader_input/2010/12/05") 
dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/autoloader_input/2010/12/06") 
dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/autoloader_input/2010/12/07")

# COMMAND ----------

# Create checkpoint location in Volume 
# RocksDB is used to manage checkpoints - https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/production#file-event-tracking
dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/checkpoint/autoloader")

# COMMAND ----------

# Copy files to nested location
dbutils.fs.cp("/databricks-datasets/definitive-guide/data/retail-data/by-day/2010-12-01.csv", "/Volumes/dev/bronze/landing/autoloader_input/2010/12/01")
dbutils.fs.cp("/databricks-datasets/definitive-guide/data/retail-data/by-day/2010-12-02.csv", "/Volumes/dev/bronze/landing/autoloader_input/2010/12/02")
dbutils.fs.cp("/databricks-datasets/definitive-guide/data/retail-data/by-day/2010-12-03.csv", "/Volumes/dev/bronze/landing/autoloader_input/2010/12/03")

# COMMAND ----------

# Read files using Autoloader with checkpoint
# and schema location "/Volumes/dev/bronze/landing/checkpoint/autoloader"
# File Detection Modes
# - Directory Listing (uses API calls to detect new files - default option)
# - File notification (uses cloud provider notification and queue services - requires elevated cloud permissions for setup)

df = (
    spark
    .readStream
    .format("cloudFiles")
    .option("cloudFiles.format", "csv")
    .option("pathGlobFilter", "*.csv")
    .option("header", "true")
    # .option("cloudFiles.useNotifications", True) # Enables the file notification mode, elevated permissions are still required
    .option("cloudFiles.schemaHints", "Quantity int, UnitPrice double") # Defines schema for specific columns
    .option("cloudFiles.schemaLocation", "/Volumes/dev/bronze/landing/checkpoint/autoloader/1/")
    # .option("cloudFiles.schemaEvolutionMode", "rescue") # Default is addNewColumns - https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/schema#how-does-auto-loader-schema-evolution-work
    .load("/Volumes/dev/bronze/landing/autoloader_input/*")
)

# COMMAND ----------

# Write data to delta table - dev.bronze.invoice_al_1

# Running in once/availableNow and processingTime mode
# Write the output to console sink to check the output
# When trigger is set to once/availableNow, it runs one batch query and stops 
# When trigger is set to processingTime, it runs a batch query every 10 seconds

from pyspark.sql.functions import col

(
    df
    .withColumn("__file", col("_metadata.file_name"))
    .writeStream
    .option("checkpointLocation", "/Volumes/dev/bronze/landing/checkpoint/autoloader/1/")
    .outputMode ("append")
    .trigger(availableNow=True)
    .toTable("dev.bronze.invoice_al_1")
)

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Shows the records processed per file
# MAGIC select __file, count(1)
# MAGIC from dev.bronze.invoice_al_1
# MAGIC group by __file
# MAGIC
# MAGIC -- To confirm that the files are processed only once, run the readStream command again and verify that the values remain unchanged

# COMMAND ----------

# Add another file to show that only delta files are processed
dbutils.fs.cp("/databricks-datasets/definitive-guide/data/retail-data/by-day/2010-12-05.csv", "/Volumes/dev/bronze/landing/autoloader_input/2010/12/05")

df = (
    spark
    .readStream
    .format("cloudFiles")
    .option("cloudFiles.format", "csv")
    .option("pathGlobFilter", "*.csv")
    .option("header", "true")
    .option("cloudFiles.schemaHints", "Quantity int, UnitPrice double") # Defines schema for specific columns
    .option("cloudFiles.schemaLocation", "/Volumes/dev/bronze/landing/checkpoint/autoloader/1/")
    .load("/Volumes/dev/bronze/landing/autoloader_input/*")
)

(
    df
    .withColumn("__file", col("_metadata.file_name"))
    .writeStream
    .option("checkpointLocation", "/Volumes/dev/bronze/landing/checkpoint/autoloader/1/")
    .outputMode ("append")
    .trigger(availableNow=True)
    .toTable("dev.bronze.invoice_al_1")
)

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Shows the records processed per file
# MAGIC select __file, count(1)
# MAGIC from dev.bronze.invoice_al_1
# MAGIC group by __file
# MAGIC
# MAGIC -- Only the new file is processed