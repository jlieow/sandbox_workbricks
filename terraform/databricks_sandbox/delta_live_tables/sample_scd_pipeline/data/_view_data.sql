-- Databricks notebook source
-- View all records where c_custkey = 6

SELECT * FROM _jlieow_dev.bronze.customer_raw
where c_custkey = 6
;

-- COMMAND ----------

-- View SCD Type 1 Table after running the pipeline
-- SCD Type 1 simply overwrites old data with new data, so only the most current value is retained and no history is kept.

select * from _jlieow_dev.etl.customer_scd1_bronze
where c_custkey = 6
;
-- COMMAND ----------

-- View SCD Type 2 Table after running the pipeline
-- SCD Type 2 adds a new row to the dimension table each time a change occurs, preserving historical versions and enabling the tracking of changes over time.
-- Any updates will result in 

-- Excluded columns _src_action and _src_insert_dt
-- __START_AT has the same data as _src_insert_dt

select * from _jlieow_dev.etl.customer_scd2_bronze
where c_custkey = 6
;