-- Databricks notebook source
-- MAGIC %md
-- MAGIC COPY_INTO loads data from a file location into a Delta table. This is a retryable and idempotent operation — Files in the source location that have already been loaded are skipped.
-- MAGIC
-- MAGIC Suitable to load a few thousands files, however beyond this or if you have a complex nested data structure, use AUTO_LOADER.

-- COMMAND ----------

-- Create new managed Volume LANDING under dev › bronze
CREATE VOLUME IF NOT EXISTS dev.bronze.landing
COMMENT 'This is Landing Managed Volume'
;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC # Create new folder called input under LANDING volume
-- MAGIC dbutils.fs.mkdirs("/Volumes/dev/bronze/landing/input")

-- COMMAND ----------

-- MAGIC %python
-- MAGIC # Copy retail invoice data from databricks-datasets
-- MAGIC dbutils.fs.cp("/databricks-datasets/definitive-guide/data/retail-data/by-day/2010-12-01.csv", "/Volumes/dev/bronze/landing/input")

-- COMMAND ----------

-- MAGIC %python
-- MAGIC # Copy retail invoice data from databricks-datasets
-- MAGIC dbutils.fs.cp("/databricks-datasets/definitive-guide/data/retail-data/by-day/2010-12-02.csv", "/Volumes/dev/bronze/landing/input")

-- COMMAND ----------

-- Create placeholder table dev. bronze. invoice_cp
CREATE TABLE IF NOT EXISTS dev.bronze.invoice_cp
;

-- COMMAND ----------

-- Use COPY INTO to load data into place holder table
COPY INTO dev.bronze.invoice_cp
FROM "/Volumes/dev/bronze/landing/input"
FILEFORMAT = CSV
PATTERN = '*csv'
FORMAT_OPTIONS (
  'mergeschema' = 'true', -- tells the system to infer the schema across multiple source files and merge them. This is useful when your input files might have slight schema variations.
  'header' = 'true'
)
COPY_OPTIONS (
  'mergeschema' = 'true'
)

-- COMMAND ----------

-- View data from table
SELECT * FROM dev.bronze.invoice_cp;

-- COMMAND ----------

-- Describe table
DESCRIBE EXTENDED dev.bronze.invoice_cp;

-- A _copy_into_log is kept at the location which tracks which files in the source location have already been loaded.

-- COMMAND ----------

-- Create new table with only 3 columns invoice_cp_alt and custom columns _ insert_date

CREATE TABLE dev.bronze.invoice_cp_alt (
  InvoiceNo string,
  StockCode string,
  Quantity double,
  _insert_date timestamp
)
;

-- COMMAND ----------

-- Load select data using COPY INTO in the new table invoice_cp_alt 
COPY INTO dev.bronze.invoice_cp_alt
FROM (
  SELECT InvoiceNo, StockCode, cast(Quantity AS DOUBLE) Quantity, current_timestamp() _insert_date
  FROM
  "/Volumes/dev/bronze/landing/input"
)
FILEFORMAT = CSV
PATTERN = '*csv'
FORMAT_OPTIONS (
  'mergeschema' = 'true', -- tells the system to infer the schema across multiple source files and merge them. This is useful when your input files might have slight schema variations.
  'header' = 'true'
)
COPY_OPTIONS (
  'mergeschema' = 'true'
)

-- COMMAND ----------

SELECT * FROM dev.bronze.invoice_cp_alt;