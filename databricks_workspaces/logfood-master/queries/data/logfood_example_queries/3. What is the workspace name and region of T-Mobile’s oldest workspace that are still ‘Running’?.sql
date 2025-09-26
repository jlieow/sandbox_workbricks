-- Databricks notebook source
-- Question from https://employee-academy.databricks.com/learn/courses/3504/fe-onboarding-role-specific-and-fe-resources/lessons/32721:2333/logfood?generated_by=410770&hash=727e6c0cd7bf2040c411bc8269899cc2a8e7e216

SELECT 
  workspace_name,
  data_plane_region,
  creation_ts,
  customer_id
FROM 
  certified.workspaces_latest
WHERE
  customer_id IN (
    SELECT 
      sfdcAccountId as customer_id
    FROM 
      main.data_df_metering.workloads_sku_agg 
    WHERE
      sfdcAccountName = "T-Mobile"
    LIMIT 1
  ) AND
  workspace_status = "RUNNING"
ORDER BY 
  creation_ts ASC
LIMIT 5