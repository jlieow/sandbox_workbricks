# Network Configuration

```
networks:
  kafka-net:
    driver: bridge
```

This creates an isolated network for our Kafka cluster, ensuring secure communication between containers.

# Broker Configuration

Each broker has several important settings:

Process Roles:

```
KAFKA_PROCESS_ROLES: 'broker,controller'
```

This enables KRaft mode with each broker also acting as a controller.

Listeners:

```
KAFKA_LISTENERS: 'PLAINTEXT://kafka1:9092,CONTROLLER://kafka1:9093'
KAFKA_ADVERTISED_LISTENERS: 'PLAINTEXT://kafka1:9092'
```

These configure how other clients and brokers connect to the cluster. For more details check this link.

# Replication Settings:

```
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
KAFKA_DEFAULT_REPLICATION_FACTOR: 3
KAFKA_MIN_INSYNC_REPLICAS: 2
```

KAFKA_MIN_INSYNC_REPLICAS: Specifies the minimum number of replicas that must acknowledge a write operation.

KAFKA_DEFAULT_REPLICATION_FACTOR: This setting determines how many copies of each partition are created across the cluster

KAFKA_OFFSET_TOPIC_REPLICATION_FACTOR: Controls replication for the special __consumer_offsets topic. This topic tracks consumer group positions (which messages have been read). Value 3 means consumer offsets are stored on 3 different broker

# Test the Cluster

Create a topic:
```
docker exec -it kafka1 kafka-topics \
    --create \
    --topic test-topic \
    --bootstrap-server kafka1:9092 \
    --replication-factor 3 \
    --partitions 3
```

List all topics:
```
docker exec -it kafka1 kafka-topics \
    --list \
    --bootstrap-server kafka1:9092
```

Describe the topic to verify replication:
```
docker exec -it kafka1 kafka-topics \
    --describe \
    --topic test-topic \
    --bootstrap-server kafka1:9092
```

# Monitoring with Kafka UI

To access the Kafka UI, simply navigate to http://localhost:8080 in your browser. Depending on where your Kafka cluster is running, you may need to use either the localhost address or the VM's IP address.

# Production Considerations
1. Security
For production environments, consider:

Enabling SSL/TLS encryption
Implementing SASL authentication
Setting up ACLs
Securing the Kafka UI
2. Performance Tuning
Key areas to consider:

Adjust replica fetch max bytes
Configure appropriate batch size
Set proper retention policies
Monitor and adjust JVM heap sizes
3. Monitoring
Implement:

Prometheus metrics
Grafana dashboards
Alert management
Log aggregation