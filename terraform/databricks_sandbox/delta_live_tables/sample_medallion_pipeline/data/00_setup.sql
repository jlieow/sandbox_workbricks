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