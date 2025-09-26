-- Databricks notebook source
-- Question from https://docs.google.com/presentation/d/1HvZaoBg3g92jwjBTKHQL_y-PlZ-DWUHfdBPZpDt6GUg/edit?slide=id.g33a7ced077a_0_2#slide=id.g33a7ced077a_0_2

-- SELECT date
-- FROM main.fin_live_gold.paid_usage_metering F
-- WHERE F.sfdc_account_name = 'Nike'
-- ORDER BY date ASC
-- LIMIT 1;

SELECT F.sku                             as sku
   , ROUND(SUM(F.usage_dollars_at_list)) as list_dollars
   , ROUND(SUM(F.usage_dollars))         as dollar_dbus
   , ROUND(SUM(F.usage_amount))          as dbus
FROM main.fin_live_gold.paid_usage_metering F
WHERE F.date >= add_months(current_date(), -24)
  AND F.date < add_months(current_date(), -12)
AND F.sfdc_account_name = 'Nike'
GROUP BY F.sku
ORDER BY 1;