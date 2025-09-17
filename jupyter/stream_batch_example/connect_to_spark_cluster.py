# Locate the Spark cluster endpoint at localhost:8080
# spark-submit --master spark://e32a4604fcd1:7077 --num-executors 2 --executor-cores 1 --executor-memory 512M connect_to_spark_cluster.py

# Spark Session
from pyspark.sql import SparkSession

spark = (
    SparkSession
    .builder
    .appName("Cluster Execution")
    .getOrCreate()
)

df = spark.range(10)

df.write.format("csv").option("header", True).save("data/output/connect_to_spark_cluster/range.csv")