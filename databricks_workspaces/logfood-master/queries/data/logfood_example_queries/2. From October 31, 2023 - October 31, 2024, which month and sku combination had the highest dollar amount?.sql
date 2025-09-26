-- Databricks notebook source
-- Question from https://employee-academy.databricks.com/learn/courses/3504/fe-onboarding-role-specific-and-fe-resources/lessons/32721:2333/logfood?generated_by=410770&hash=727e6c0cd7bf2040c411bc8269899cc2a8e7e216

SELECT 
  SUM(dollarsWithAddOns) AS total_dollars,
  CONCAT(YEAR(date), "_", MONTH(date), "_", sku) AS month_sku
FROM 
  main.data_df_metering.workloads_sku_agg 
WHERE
  date BETWEEN "2023-10-31" AND "2024-10-31"
GROUP BY
  CONCAT(YEAR(date), "_", MONTH(date), "_", sku)
ORDER BY 
  total_dollars DESC
LIMIT 12