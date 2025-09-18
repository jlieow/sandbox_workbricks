Exec into broker 
```
docker exec -it cf-kafka-1 /bin/bash
```

List all topics 
```
kafka-topics --list --bootstrap-server localhost:29092
```

Create topic 
```
kafka-topics --create --topic test-topic --bootstrap-server localhost:29092
```

Describe topic 
```
kafka-topics --describe --topic test-topic --bootstrap-server localhost:29092
```

When you describe a topic it returns something like this:
```
Topic: test-topic       TopicId: Hk238ePGQAqsFc3HDDFwxw PartitionCount: 1       ReplicationFactor: 1    Configs: 
        Topic: test-topic       Partition: 0    Leader: 3       Replicas: 3     Isr: 3
```

When you do not specify any partition number or replication factor, the topic only has 1 partition and a single replication factor and the leader of the partition is broker 3.

To create a topic with 3 partitions and a replicaton factor of 2 use:
```
kafka-topics --create --topic test-topic-a --partitions 3 --replication-factor 2 --bootstrap-server localhost:29092
```

When you describe the topic, it should now return something liek this:
```
Topic: test-topic-a     TopicId: tl51bFwXTBesAmLDmEsrYQ PartitionCount: 3       ReplicationFactor: 2    Configs: 
        Topic: test-topic-a     Partition: 0    Leader: 2       Replicas: 2,3   Isr: 2,3
        Topic: test-topic-a     Partition: 1    Leader: 3       Replicas: 3,1   Isr: 3,1
        Topic: test-topic-a     Partition: 2    Leader: 1       Replicas: 1,2   Isr: 1,2
```

To get partition offsets use
```
kafka-get-offsets --topic test-topic-a --bootstrap-server localhost:29092
```

For older cp-kafka images `kafka-get-offsets` might not be available, try:
```
kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:29092 --topic test-topic-a
```

The first number is the partition and the second number is the offset. Since there are no messages, the offset is currently set to 0:
```
test-topic-a:0:0
test-topic-a:1:0
test-topic-a:2:0
```

To publish messages to the topic use:
```
kafka-console-producer --topic test-topic-a --bootstrap-server localhost:29092
``` 

If done correctly, the messages would have been pushed into the partition:
```
test-topic-a:0:0
test-topic-a:1:1
test-topic-a:2:1
```

To consume messages from a topic use:
```
kafka-console-consumer --topic test-topic-a --bootstrap-server localhost:29092
``` 

To consume OLD messages from a topic you need to provide an offset use:
```
kafka-console-consumer --topic test-topic-a --bootstrap-server localhost:29092 --partition 0 --offset earliest
``` 