# Databricks notebook source
# ISO Date Input format - 2024-10-27T13:00:00 (уууу-MM-ddTHH: mm: ss)
# Read date as input and get the day of week - Like Sun, Mon etc
# Create input_date widget
dbutils.widgets.text("input_date", "")

# COMMAND ----------

# Read value from widget
_input_date = dbutils.widgets.get("input_date")
print(_input_date)

# COMMAND ----------

# Set conf to LEGACY to support datetime patterns
spark.conf.set("spark.sql.legacy.timeParserPolicy", "LEGACY")
_input_day = spark.sql (f"""
                        select date_format(to_timestamp('{_input_date}', "yyyy-MM-dd'T'HH:mm:ss"), 'E')
                        """).collect()[0][0]
print(_input_day)

# COMMAND ----------

# Export the day of week using taskValues to use in next task
dbutils.jobs.taskValues.set("input_day", _input_day)