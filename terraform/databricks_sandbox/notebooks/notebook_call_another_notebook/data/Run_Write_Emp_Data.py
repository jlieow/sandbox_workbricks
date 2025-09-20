# Databricks notebook source
# Run the child notebook with Parameter - sales or production or office
_count = dbutils.notebook.run(
    "Write_Emp_Data",
    600,
    {"dept" : "office"} # Pass in the parameters to the notebook
)

# COMMAND ----------

print(f"Child notebook count: {_count}")