-- Databricks notebook source
-- Cleans up dangling resources to ensure idempotency
DROP SCHEMA IF EXISTS _jlieow_dev.etl CASCADE;
DROP TABLE IF EXISTS _jlieow_dev.bronze.orders_raw;
DROP TABLE IF EXISTS _jlieow_dev.bronze.customer_raw;

-- COMMAND ----------

-- CREATE NEW SCHEMA
CREATE SCHEMA IF NOT EXISTS _jlieow_dev.etl
COMMENT 'SCHEMA FOR DLT INTRODUCTION';

-- COMMAND ----------

-- CLONE SOME SAMPLE TABLES
CREATE TABLE IF NOT EXISTS _jlieow_dev.bronze.orders_raw DEEP CLONE samples.tpch.orders;
CREATE TABLE IF NOT EXISTS _jlieow_dev.bronze.customer_raw DEEP CLONE samples. tpch. customer;

-- COMMAND ----------

SELECT * FROM _jlieow_dev.bronze.orders_raw;

-- COMMAND ----------

SELECT * FROM _jlieow_dev.bronze.customer_raw;

-- COMMAND ----------

-- Create Volume for Autoloader
CREATE VOLUME IF NOT EXISTS _jlieow_dev.etl.landing
COMMENT 'Volume for Source Files'
;

-- COMMAND ----------

-- MAGIC %python 
-- MAGIC # Create directories for Autoloader cloudFiles streaming source and checkpoint
-- MAGIC dbutils.fs.mkdirs("/Volumes/_jlieow_dev/etl/landing/files")
-- MAGIC dbutils.fs.mkdirs("/Volumes/_jlieow_dev/etl/landing/autoloader/schemas")

-- COMMAND ----------

-- Add columns in Source customer_raw table for customer bronze SCD Tables
ALTER TABLE _jlieow_dev.bronze.customer_raw
ADD COLUMNS (
  _src_action STRING, -- Possible Values I, D, T 
  _src_insert_dt TIMESTAMP
);

-- COMMAND ----------

-- Update the new columns _src_insert_dt and _src_action
UPDATE _jlieow_dev.bronze.customer_raw
SET _src_action = 'I',
    _src_insert_dt = current_timestamp() - interval '3 days'
;