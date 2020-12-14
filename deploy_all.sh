#!/bin/bash
set -x

for i in {1..10}
do
  kubectl create ns pingsource$i
  kubectl create ns kafkasource$i
  kubectl create ns apiserversource$i
  kubectl apply -n pingsource$i -f $(dirname "${BASH_SOURCE[0]}")/pingsource/
  kubectl apply -n kafkasource$i -f $(dirname "${BASH_SOURCE[0]}")/kafkasource/sink-service.yaml
  kubectl apply -n kafkasource$i -f $(dirname "${BASH_SOURCE[0]}")/kafkasource/ksource.yaml
  echo "$(yq w -d'1' ./apisource/rbac.yaml subjects.[0].namespace apiserversource$i)" > /tmp/rb.yaml
  echo "$(yq w -d'1' /tmp/rb.yaml metadata.name k8s-ra-event-watcher$i)" | kubectl apply -f -
  kubectl apply -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/api-server-source.yaml
  kubectl apply -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/broker.yaml
  kubectl apply -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/service-sink.yaml
  kubectl apply -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/service-account.yaml
  kubectl apply -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/trigger.yaml
done
