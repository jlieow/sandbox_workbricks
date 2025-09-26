-- Databricks notebook source
-- Question from https://employee-academy.databricks.com/learn/courses/3504/fe-onboarding-role-specific-and-fe-resources/lessons/32721:2333/logfood?generated_by=410770&hash=727e6c0cd7bf2040c411bc8269899cc2a8e7e216

SELECT 
  sku,
  SUM(dbus) as total_dbus
FROM 
  main.data_df_metering.workloads_sku_agg 
WHERE
  sfdcAccountName = "T-Mobile" AND
  date = "2024-10-31"
GROUP BY
  sku
ORDER BY 
  total_dbus DESC
LIMIT 10