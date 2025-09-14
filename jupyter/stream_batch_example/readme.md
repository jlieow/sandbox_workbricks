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

Some example device-data message:
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

Some example device-data message:
1. `{"eventId": "e3cb26d3-41b2-49a2-84f3-0156ed8d7502", "eventOffset": 10001, "eventPublisher": "device", "customerId": "CI00103", "data": {"devices": [{"deviceId": "D001", "temperature": 15, "measure": "C", "status": "ERROR"}, {"deviceId": "D002", "temperature": 16, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.643364"}`

2. `{"eventId": "aa90011f-3967-496c-b94b-a0c8de19a3d3", "eventOffset": 10003, "eventPublisher": "device", "customerId": "CI00108", "data": {"devices": [{"deviceId": "D004", "temperature": 16, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.643364"}`

3. `{"eventId": "1450324a-c546-4175-a6d8-ee58822e1d41", "eventOffset": 10038, "eventPublisher": "device", "customerId": "CI00101", "data": {"devices": [{"deviceId": "D004", "temperature": 20, "measure": "C", "status": "SUCCESS"}, {"deviceId": "D004", "temperature": 1, "measure": "C", "status": "SUCCESS"}, {"deviceId": "D002", "temperature": 21, "measure": "C", "status": "SUCCESS"}]}, "eventTime": "2023-01-05 11:13:53.650313"}`

Some examples of malformed data:

1. `hello world`

2. `{"eventId": "a920562e-e8c0-4884-ad28-b74d82fc9ad8", "eventOffset": 10018, "eventPublisher": "device", "customerId": "CI00118", "data": {"devices": []}, "eventTime": "2023-01-05 11:13:53.649684"}`

To trigger the exception, you can stop the PSQL DB.