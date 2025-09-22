-- Databricks notebook source
-- Insert changed record for cust_key 6

INSERT INTO _jlieow_dev.bronze.customer_raw
VALUES ( 
  6, 'Customer#000412450', 'fUD6IoGdtF', 20, '30-293-696-5047', 4406.28, 'BUILDING', 'New Changed Record', 'I', current_timestamp() 
);

-- COMMAND ----------

-- Insert changed record for cust_key 6 for backfilling
-- Backfilling is the process of retroactively filling in missing or incomplete data in a dataset, database, or system.

INSERT INTO _jlieow_dev.bronze.customer_raw
VALUES (
  6, 'Customer#000412450', 'fUD6I0GdtF', 20, '30-293-696-5047', 4406.28, 'BUILDING', 'Old Record for Backfill', 'I', current_timestamp() - interval '1 days'
);

-- COMMAND ----------

-- Insert delete record for cust_key 6
-- SCD 1 monitors the column specified in apply_as_deletes for deletes and deletes the record
-- SCD 2 will continue to add another record as no column was specified in apply_as_deletes for deletes

INSERT INTO _jlieow_dev.bronze.customer_raw
VALUES (
  6, 'Customer#000412450', 'fUD6I0GdtF', 20, '30-293-696-5047', 4406.28, 'BUILDING', 'Old Record for Backfill', 'D', current_timestamp()
);

-- COMMAND ----------

-- Insert truncate record for cust_key 6
-- SCD 1 monitors the column specified in apply_as_truncates for truncate and truncates the table
-- SCD 2 will continue to add another record as no column was specified in apply_as_truncates for deletes

INSERT INTO _jlieow_dev.bronze.customer_raw
VALUES (
  null, 'Customer#000412450', 'fUD6I0GdtF', 20, '30-293-696-5047', 4406.28, 'BUILDING', 'Old Record for Backfill', 'T', current_timestamp()
);
