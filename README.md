### Deploy a number of Eventing Sources and Services for development/testing purposes

0. Get access to an ocp cluster or use crc.
1. clone https://github.com/openshift-knative/serverless-operator and run `make install-all`
2. run: `deploy_all.sh`
3. run: `crc console` and check Knative dashboards
4. For the kafka sources create some load with:
```
kubectl -n kafka run kafka-producer -ti --image=strimzi/kafka:0.20.0-kafka-2.6.0 --rm=true --restart=Never -- sh -c 'for i in {1..100000}; do echo test$i; done | bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka.svc:9092 --topic knative-demo-topic'
```
To check if records are being written use:
```
kubectl -n kafka run kafka-consumer -ti --image=strimzi/kafka:0.20.0-kafka-2.6.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka.svc:9092 --topic knative-demo-topic --from-beginning
```
