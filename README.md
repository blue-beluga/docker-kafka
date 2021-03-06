
# [<img src=".bluebeluga.png" height="100" width="200" style="border-radius: 50%;"/>](https://github.com/blue-beluga/docker-kafka) bluebeluga/kafka

[Kafka](http://kafka.apache.org/) is a distributed, partitioned, replicated commit log service.

## Installation and Usage

This image can be used in several different ways. All require an running Zookeeper service, which is either running locally via the container named `zookeeper` or with a zookeeper service.

### Start a Kafka broker

Starting a Kafka broker using this image is simple:

    docker run -d --name kafka -p 9092:9092 --link zookeeper:zookeeper bluebeluga/kafka

### Create a topic on a running broker

If you already have one or more running containers with a Kafka broker, you can use this image to start _another_ container that connects to the running broker(s) and uses them to create a topic:

    docker run -it --rm --link zookeeper:zookeeper bluebeluga/kafka create-topic [-p numPartitions] [-r numReplicas] topic-name

where `topic-name` is the name of the new topic, `numPartitions` is the number of partitions within the new topic, and `numReplicas` is the number of replicas for each partition within the new topic. The default for both `numPartitions` and `numReplicas` is '1'.

The container will exit as soon as the request to create the topic completes, and because `--rm` is used the container will be immediately removed.

Simply run this command once for each topic you want to create.

### Watch a topic on a running broker

If you already have one or more running containers with a Kafka broker, you can use this image to start _another_ container that connects to the running broker(s) and watches a topic:

    docker run -it --rm --link zookeeper:zookeeper bluebeluga/kafka watch-topic [-a] topic-name

where `topic-name` is the name of the topic, and `-a` is the optional flag that specifies that all of the topic messages should be displayed (e.g., from the beginning).

### Listing topics on a running broker

If you already have one or more running containers with a Kafka broker, you can use this image to start _another_ container that connects to the running broker(s) and lists the exisitng topics:

    docker run -it --rm --link zookeeper:zookeeper bluebeluga/kafka list-topics

The container will exit (and be removeD) immediately after the response is displayed.

## Environment variables

The Kafka image uses several environment variables when running a Kafka broker using this image.

### `BROKER_ID`

This environment variable is recommended. Set this to the unique and persistent number for the broker. This must be set for every broker in a Kafka cluster, and should be set for a single standalone broker. The default is '1', and setting this will update the Kafka configuration.

### `ZOOKEEPER_CONNECT`

This environment variable is recommended, although linking to a `zookeeper` container precludes the need to use it. Otherwise, set this to a string described in the Kafka documentation for the 'zookeeper.connect' property so that the Kafka broker can find the Zookeeper service. Setting this will update the Kafka configuration.

### `HOST_NAME`

This environment variable is a recommended setting. Set this to the hostname that the the REST API will bind to. Defaults to the hostname of the container.

### `ADVERTISED_HOST_NAME`

This environment variable is an recommended setting. Set this to the hostname that will be given out to other workers to connect with. Defaults to the hostname of the container.

### `HEAP_OPTS`

This environment variable is recommended. Use this to set the JVM options for the Kafka broker. By default a value of '-Xmx1G -Xms1G' is used, meaning that each Kafka broker uses 1GB of memory. Using too little memory may cause performance problems, while using too much may prevent the broker from starting properly given the memory available on the machine. Obviously the container must be able to use the amount of memory defined by this environment variable.

### `CREATE_TOPICS`

This environment variable is optional. Use this to specify the topics that should be created as soon as the broker starts. The value should be a comma-separated list of topics, partitions, and replicas. For example, when this environment variable is set to `topic1:1:2,topic2:3:1`, then the container will create 'topic1' with 1 partition and 2 replicas, and 'topic2' with 3 partitions and 1 replica.

### `LOG_LEVEL`

This environment variable is optional. Use this to set the level of detail for Kafka's application log written to STDOUT and STDERR. Valid values are `INFO` (default), `WARN`, `ERROR`, `DEBUG`, or `TRACE`."

### Others

Environment variables that start with `KAFKA_` will be used to update the Kafka configuration file. Each environment variable name will be mapped to a configuration property name by:

1. removing the `KAFKA_` prefix;
2. lowercasing all characters; and
3. converting all '_' characters to '.' characters

For example, the environment variable `KAFKA_ADVERTISED_HOST_NAME` is converted to the `advertised.host.name` property, while `KAFKA_AUTO_CREATE_TOPICS_ENABLE` is converted to the `auto.create.topics.enable` property. The container will then update the Kafka configuration file to include the property's name and value.

The value of the environment variable may not contain a '\@' character.

## Ports

Containers created using this image will expose port 9092, which is the standard port used by Kafka.  You can  use standard Docker options to map this to a different port on the host that runs the container.

## Data Volumes

The Kafka broker run by this image writes data to the local file system, and the only way to keep this data is to use volumes that map specific directories inside the container to the local file system (or to OpenShift persistent volumes).

### Topic data

This image defines a data volume at `/kafka/data`. The broker writes all persisted data as files within this directory, inside a subdirectory named with the value of BROKER_ID (see above). You must mount it appropriately when running your container to persist the data after the container is stopped; failing to do so will result in all data being lost when the container is stopped.

### Log files

Although this image will send Kafka broker log output to standard output so it is visible in the Docker logs, this image also configures Kafka to write out more detailed logs to a data volume at `/kafka/logs`. All logs are rotated daily, and include:

* `server.log` - Contain the same log output sent to standard output and standard error.
* `state-change.log` - Records the timeline of requested and completed state changes between the controller and brokers.
* `kafka-request.log` - Records one entry for each of the request received and handled by the broker.
* `log-cleaner.log` - Records the detail about log compaction, whereby Kafka ensures that a compacted topic retains at least the last value for each distinct message key.
* `controller.log` - Records controller activities, such as the brokers that make up the in-sync replicas for each partition and the brokers that are the leaders of their partitions.

### Configuration

This image defines a data volume at `/kafka/config` where the broker's configuration files are stored. Note that these configuration files are always modified based upon the environment variables and linked containers. The best use of this data volume is to be able to see the configuration files used by Kafka, although with some care it is possible to supply custom configuration files that will be adapted and used upon startup.
