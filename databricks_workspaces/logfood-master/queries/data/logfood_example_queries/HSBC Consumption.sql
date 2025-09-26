-- Databricks notebook source
-- Question from https://docs.google.com/presentation/d/1HvZaoBg3g92jwjBTKHQL_y-PlZ-DWUHfdBPZpDt6GUg/edit?slide=id.g33a7ced077a_0_2#slide=id.g33a7ced077a_0_2

SELECT F.sku                             as sku
   , ROUND(SUM(F.usage_dollars_at_list)) as list_dollars
   , ROUND(SUM(F.usage_dollars))         as dollar_dbus
   , ROUND(SUM(F.usage_amount))          as dbus
FROM main.fin_live_gold.paid_usage_metering F
WHERE F.`date` >= to_date('2025-01-01', 'yyyy-MM-dd')
AND F.`date` <= to_date('2025-01-31', 'yyyy-MM-dd')
AND F.sfdc_account_name = 'HSBC'
AND F.sfdc_workspace_name in ('payme-dbx-prod-main',
                          'payme-workspace-uat-main',
                          'payme-dbx-prod-ds')
GROUP BY F.sku
ORDER BY 1;