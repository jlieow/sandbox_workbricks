# Jupter notebook

Examples require a Jupyter notebook. Spin one up in a container with:
```
DIR=/Users/jerome.lieow/Documents/Jupyter
docker run --user root -v $DIR:/home/jovyan \
  -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R' \
  -it -d -p 8888:8888 -p 4040:4040 --name jupyter quay.io/jupyter/pyspark-notebook
docker logs jupyter
```

| Port | Purpose |
| :-- | :-- |
| 8888 | Jupyter Notebook |
| 4040 | Spark UI |

To delete directory with contents use `rm -f dir`

## JAR Files

To search for JAR packages search [Maven Central Repository](https://central.sonatype.com/). For each package, Maven Central provides the dependency snippet (groupId:artifactId:version).

Example: org.apache.spark:spark-sql_2.12:3.5.0

# stream_example

Exec into the jupyter notebook, install netcat and start listening for connections on port 9999.

Execute pyspark to connect to port 9999.

Stream text via netcat through port 9999 to spark.

# stream_file

Use the files `device_01.json`, `device_02.json` and `device_03.json` located in `data > samples`. 

In the jupyter notebook, deposit it into `data > input > device_data`. The example ingest files deposited in the directory.

# stream_from_kafka_manual

Run `docker compose up` in directory images > kafka-cluster-with-jupyter-notebook.

Prepare Kafka to stream to spark in docker:
```
docker exec -it cf-kafka-1 /bin/bash 
kafka-topics --create --topic device-data --bootstrap-server localhost:29092
kafka-topics --list --bootstrap-server localhost:29092

kafka-console-producer --topic device-data --bootstrap-server localhost:29092
```

# stream_from_kafka_auto

Run `docker compose up` in directory images > kafka-cluster-with-jupyter-notebook.

Prepare a Kafka topic for a python script which will be described later:
```
docker exec -it cf-kafka-1 /bin/bash 
kafka-topics --create --topic device-data --bootstrap-server localhost:29092
kafka-topics --list --bootstrap-server localhost:29092
```

This example will utilise 2 python scripts `device_events.py` and `post_to_kafka.py`

device_events.py - Generates random device events data in json format
post_to_kafka.py - Instantiates a Kafka producer and publishes device events data in json format to Kafka

post_to_kafka.py requires installation of kafka-python with `pip install kafka-python`.

Start publishing data to Kafka with `python post_to_kafka.py`

To increase the number of partitions of our topic use:
```
docker exec -it cf-kafka-1 /bin/bash 
kafka-topics --alter --topic device-data --partitions 8 --bootstrap-server localhost:29092
```

# stream_from_kafka_to_multiple_sinks

Run `docker compose up` in directory images > kafka-cluster-with-jupyter-notebook.

In sqlpad to prepare PSQL DB, execute:
```
CREATE TABLE IF NOT EXISTS public.device_data (
	customerid varchar,
	eventid varchar,
	eventoffset varchar,
	eventpublisher varchar,
	eventtime varchar,
	deviceid varchar,
	measure varchar,
	status varchar,
	temperature varchar
);

SELECT * FROM device_data;
```

Prepare a Kafka topic for a python script which will be described later:
```
docker exec -it cf-kafka-1 /bin/bash 
kafka-topics --create --topic device-data --bootstrap-server localhost:29092
kafka-topics --list --bootstrap-server localhost:29092
kafka-console-producer --topic device-data --bootstrap-server localhost:29092
```

Some example device-data messages:
1. `{"eventId": "e3cb26d3-41b2-49a2-84f3-0156ed8d7502", "eventOffset": 10001, "eventPublisher": "device", "customerId": "CI00103", "data": {"devices": [{"deviceId": "D001", "temperature": 15, "measure": "C", "status": "ERROR"}, {"deviceId": "D002", "temperature": 16, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.643364"}`

2. `{"eventId": "aa90011f-3967-496c-b94b-a0c8de19a3d3", "eventOffset": 10003, "eventPublisher": "device", "customerId": "CI00108", "data": {"devices": [{"deviceId": "D004", "temperature": 16, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.643364"}`

3. `{"eventId": "1450324a-c546-4175-a6d8-ee58822e1d41", "eventOffset": 10038, "eventPublisher": "device", "customerId": "CI00101", "data": {"devices": [{"deviceId": "D004", "temperature": 20, "measure": "C", "status": "SUCCESS"}, {"deviceId": "D004", "temperature": 1, "measure": "C", "status": "SUCCESS"}, {"deviceId": "D002", "temperature": 21, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.650313"}`

## Errors

If you receive such an error: `Some data may have been lost because they are not available in Kafka any more; either the data was aged out by Kafka or the topic may have been deleted before all the data in the topic was processed.`

Delete the checkpoint directory as Spark ma be referencing offsets that no longer exist with `rm -rf dir`

To delete data from PSQL use `TRUNCATE public.device_data;`
```
TRUNCATE public.device_data;
DELETE FROM public.device_data;
```

# stream_from_kafka_with_error_exception_handling

This example demonstrates a simple example of how to perform error and exception handling. In this example errors are sent to an error table whilst exceptions are saved as a file to a blob storage location.

Run `docker compose up` in directory images > kafka-cluster-with-jupyter-notebook.

In sqlpad to prepare PSQL DB, execute:
```
CREATE TABLE IF NOT EXISTS public.device_data (
	customerid varchar,
	eventid varchar,
	eventoffset varchar,
	eventpublisher varchar,
	eventtime varchar,
	deviceid varchar,
	measure varchar,
	status varchar,
	temperature varchar
);

CREATE TABLE IF NOT EXISTS public.device_data_error (
	key varchar,
	value varchar,
	eventtimestamp timestamp,
	batchid int
);

SELECT * FROM device_data;

SELECT * FROM device_data_error;
```

Prepare a Kafka topic for a python script which will be described later:
```
docker exec -it cf-kafka-1 /bin/bash 
kafka-topics --create --topic device-data --bootstrap-server localhost:29092
kafka-topics --list --bootstrap-server localhost:29092
kafka-console-producer --topic device-data --bootstrap-server localhost:29092
```

Some example device-data messages:
1. `{"eventId": "e3cb26d3-41b2-49a2-84f3-0156ed8d7502", "eventOffset": 10001, "eventPublisher": "device", "customerId": "CI00103", "data": {"devices": [{"deviceId": "D001", "temperature": 15, "measure": "C", "status": "ERROR"}, {"deviceId": "D002", "temperature": 16, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.643364"}`

2. `{"eventId": "aa90011f-3967-496c-b94b-a0c8de19a3d3", "eventOffset": 10003, "eventPublisher": "device", "customerId": "CI00108", "data": {"devices": [{"deviceId": "D004", "temperature": 16, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.643364"}`

3. `{"eventId": "1450324a-c546-4175-a6d8-ee58822e1d41", "eventOffset": 10038, "eventPublisher": "device", "customerId": "CI00101", "data": {"devices": [{"deviceId": "D004", "temperature": 20, "measure": "C", "status": "SUCCESS"}, {"deviceId": "D004", "temperature": 1, "measure": "C", "status": "SUCCESS"}, {"deviceId": "D002", "temperature": 21, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.650313"}`

Some examples of malformed data:

1. `hello world`

2. `{"eventId": "a920562e-e8c0-4884-ad28-b74d82fc9ad8", "eventOffset": 10018, "eventPublisher": "device", "customerId": "CI00118", "data": {"devices": []}, "eventTime": "2023-01-05 11:13:53.649684"}`

To trigger the exception, you can stop the PSQL DB and run the python script. The exception will be triggered when it attempts to connect and write to the PSQL DB.

# stream_window_watermark

This example demonstrates watermarks with fixed/tumbling and sliding/overlapping windows. It is easier to understand watermarks with fixed windows.

A watermark in Spark is a threshold that defines how late data can arrive and still be processed in a streaming application. It enables Spark to efficiently manage memory by cleaning up old, irrelevant state tied to aggregations and windows, ensuring processing scalability and preventing unbounded growth of stored data.

Run `docker compose up` in directory images > kafka-cluster-with-jupyter-notebook.

Prepare a Kafka topic for a python script which will be described later:
```
docker exec -it cf-kafka-1 /bin/bash 
kafka-topics --create --topic wildlife --bootstrap-server localhost:29092
kafka-topics --list --bootstrap-server localhost:29092
kafka-console-producer --topic wildlife --bootstrap-server localhost:29092
```

These example wildlife messages attempt to demonstrate watermarks:
```
{"event_time": "2024-04-09 11:50:00.000000", "data": "owl dog"}
{"event_time": "2024-04-09 12:01:00.000000", "data": "owl dog owl"}
{"event_time": "2024-04-09 12:03:00.000000", "data": "owl"}
{"event_time": "2024-04-09 12:05:00.000000", "data": "owl"}
{"event_time": "2024-04-09 12:13:00.000000", "data": "dog owl"}
{"event_time": "2024-04-09 12:17:00.000000", "data": "dog"}



{"event_time": "2024-04-09 11:59:00.000000", "data": "dog"}
{"event_time": "2024-04-09 12:01:00.000000", "data": "dog"}
```

Assume that the watermark and window is set for `10 minutes`. The messages above will have the following windows:
2024-04-09 11:50:00|2024-04-09 12:00:00
2024-04-09 12:00:00|2024-04-09 12:10:00
2024-04-09 12:10:00|2024-04-09 12:20:00

Only messages that is submitted in a window within the watermark will be processed. That means after the message is submitted at `2024-04-09 12:17:00.000000`, (as the watermark is 10 minutes) only messages submitted in the following windows will be processed:
2024-04-09 12:00:00|2024-04-09 12:10:00
2024-04-09 12:10:00|2024-04-09 12:20:00

Notice that watermarks do not work with windows in complete mode.

To reset delete the checkpoint directories:
```
rm -rf checkpoint_dir_kafka_2
rm -rf checkpoint_dir_kafka_3
```

And purge the kafka topic:
```
kafka-topics --delete --topic wildlife --bootstrap-server localhost:29092
kafka-topics --create --topic wildlife --bootstrap-server localhost:29092
kafka-topics --list --bootstrap-server localhost:29092
kafka-console-producer --topic wildlife --bootstrap-server localhost:29092
```

# connect_to_spark_cluster

Run `docker compose up` in directory images > spark-cluster-with-jupyter-notebook.

The volume will require `:rw`. The `:rw` option on a Docker volume means the container can both read from and write to the mounted files or directories. 

## spark submit

The usual way to submit a job to a Spark cluster is by using the `spark-submit` command: 
`spark-submit --master spark://e32a4604fcd1:7077 --num-executors 2 --executor-cores 1 --executor-memory 512M connect_to_spark_cluster.py`

# python_udf_example

To see the Spark creating a Python process to run the UDF, uncommit the `time.sleep(10)` before running the `show()` command otherwise the Python process may be deleted too quickly. 

Exec into a Spark worker to see the Python process with:
```
docker exec -it spark-worker-1 /bin/bash
ps aux
```

# databricks_partition_and_z_order_optimization

Spark partitioning physically splits data by specific column values into files or directories, making it ideal for columns with low cardinality (few distinct values), such as date or region, to improve query performance and data skipping. 

Z-order (Z-Ordering), by contrast, clusters related records within files on one or more columns, making it effective for range queries, especially when dealing with high cardinality (many distinct values) or when queries filter on multiple columns.

Take note that the default value for `spark.databricks.delta.optimize.maxFileSize` is 1073741824, which sets the size to 1 GB. For smaller file sizes this value should be reduced otherwise, all data may be packed into a single large file, diminishing the effectiveness of Z-ordering.

Liquid clustering is newer, automatically lays out data for fast queries, allows clustering columns to evolve without rewriting existing files, and handles high cardinality, skew, and frequent inserts more flexibly than Z-order.

Use Z-order for fixed query patterns and partitioning and use liquid clustering for dynamic, evolving workloads and fast incremental optimization.

# oom_error

Unzip files at `data > input > oom > spark_oom_files.7z`.

Run the script and go to `localhost:4040` to view the failing stages.

`text_file_singleline_xs.txt` is 11MB. Each record is 11MB due to the single line text. When the explode function is run, it creates a new record for each word in the single line text which dramatically increases the size of the data. As the size of the execution memory is only 23.352MB, it is unable to contain the exploded data size and throws a OOM error.

Causes of OOM Error:
1. Individual record is larger than the execution memory. Spark cannot spill individual records, it can only spill partitions.
2. During wide operations the shuffle data is larger than the execution memory.
3. Each broadcast variable is larger than the execution memory.
4. Explosion of memory results in data larger than the execution memory.
5. Expansion of memory due to deserialisation or uncompression results in data larger than the execution memory.