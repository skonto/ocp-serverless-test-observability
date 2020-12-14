#!/bin/bash
for i in {1..1000}
do
cat <<EOF | kubectl apply -f -
apiVersion: sources.knative.dev/v1beta1
kind: PingSource
metadata:
  name: ping-source-$i
spec:
  schedule: "*/1 * * * *"
  jsonData: '{"message": "Hello serverless!"}'
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1beta1
      kind: Broker
      name: default
EOF

done
