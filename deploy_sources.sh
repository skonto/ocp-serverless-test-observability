#!/bin/bash
set -x
manage_namespaces () {
  local op=$1
  echo "$(yq w -d'*' $(dirname "${BASH_SOURCE[0]}")/ns.yaml metadata.name pingsource$i)" | kubectl $op -f -
  echo "$(yq w -d'*' $(dirname "${BASH_SOURCE[0]}")/ns.yaml metadata.name kafkasource$i)" | kubectl $op -f -
  echo "$(yq w -d'*' $(dirname "${BASH_SOURCE[0]}")/ns.yaml metadata.name apiserversource$i)" | kubectl $op -f -
}

doop () {
  local op=$1
  kubectl $op -f $(dirname "${BASH_SOURCE[0]}")/topic.yaml
  for i in {1..10}
  do
    if [ "$op" = "apply" ]; then
      manage_namespaces $op
    fi

    # ping sources
    kubectl $op -n pingsource$i -f $(dirname "${BASH_SOURCE[0]}")/pingsource/

    # kafka sources
    kubectl $op -n kafkasource$i -f $(dirname "${BASH_SOURCE[0]}")/kafkasource/sink-service.yaml
    echo "$(yq w -d'*' $(dirname "${BASH_SOURCE[0]}")/kafkasource/ksource.yaml spec.consumerGroup knative-group$i)" | kubectl $op -n kafkasource$i -f -

    # apiserver sources
    echo "$(yq w -d'1' $(dirname "${BASH_SOURCE[0]}")/apisource/rbac.yaml subjects.[0].namespace apiserversource$i)" > /tmp/rb.yaml
    echo "$(yq w -d'1' /tmp/rb.yaml metadata.name k8s-ra-event-watcher$i)" | kubectl $op -f -
    kubectl $op -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/api-server-source.yaml
    kubectl $op -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/broker.yaml
    kubectl $op -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/service-sink.yaml
    kubectl $op -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/service-account.yaml
    kubectl $op -n apiserversource$i -f $(dirname "${BASH_SOURCE[0]}")/apisource/trigger.yaml
  done
}

while [[ $# -gt 0 ]]
do
  case $1 in
     --apply)
     doop "apply"
      ;;
     --delete)
     doop "delete"
      ;;
    *)
      error "Unrecognized argument $1"
      ;;
  esac
  shift
done
