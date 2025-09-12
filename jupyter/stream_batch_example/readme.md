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

# stream_file_example

Use the files `device_01.json`, `device_02.json` and `device_03.json` located in `data > samples`. 

In the jupyter notebook, deposit it into `data > input > device_data`. The example ingest files deposited in the directory.

# stream_from_kafka_manual_example

Run `docker compose up` in directory images > kafka-cluster-with-jupyter-notebook.

Prepare Kafka to stream to spark in docker:
```
docker exec -it cf-kafka-1 /bin/bash 
kafka-topics --create --topic device-data --bootstrap-server localhost:29092
kafka-topics --list --bootstrap-server localhost:29092

kafka-console-producer --topic device-data --bootstrap-server localhost:29092
```

# stream_from_kafka_auto_example

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