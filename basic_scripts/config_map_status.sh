#!/bin/bash

set -e

CONFIG_MAP_NAME="iks-ca-config"
NAMESPACE="kube-system"
COUNTER=0
MAX_ATTEMPTS=40

while [[ $COUNTER -lt $MAX_ATTEMPTS ]] && ! kubectl get configmap ${CONFIG_MAP_NAME} -n ${NAMESPACE} &>/dev/null; do
  COUNTER=$((COUNTER+1))
  echo "Retrying: ${COUNTER}/${MAX_ATTEMPTS}: Configmap `$CONFIG_MAP_NAME` not found in Namespace `${NAMESPACE}`"
  sleep 60
done

if [[ ${COUNTER} -eq ${MAX_ATTEMPTS} ]]; then
  echo "Configmap `${CONFIG_MAP_NAME}` not present. Attempted $MAX_ATTEMPTS times."
  kubectl get configmaps -n ${NAMESPACE}
  exit 1
else
  echo "Configmap `${CONFIG_MAP_NAME}` is now available." >&2
fi