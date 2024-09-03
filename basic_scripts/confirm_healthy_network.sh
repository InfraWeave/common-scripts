#!/bin/bash

set -e

function run_checks(){
    last_attempt=$1
    namespace=calico-system

    MAX_ATTEMPTS=10
    attempt=0
    PODS=()

    while [[ $attempt -lt $MAX_ATTEMPTS ]]; do
      if while IFS='' read - r line; do PODS+=("$line"); done < <(kubectl get pods -n ${namespace} | grep calico-node | cut -d ' ' -f1); then
        if [[ ${#PODS[@]} -eq 0 ]]; then
          echo "No Calico node pods found. Retrying in 10s. Attempt $((attempt+1)) / $MAX_ATTEMPTS"
          sleep 10
          ((attempt=attempt+1))
        else
          break # Pods found and break out of loop
        fi
      else
        echo "Error getting Calico node pods. Retrying in 10s. Attempt $((attempt+1)) / $MAX_ATTEMPTS"
        sleep 10
        ((attempt=attempt+1))
    done

    if [[ ${#PODS[@]} -eq 0 ]]; then
      echo "No calico-node pods found after ${MAX_ATTEMPTS} attempts. Exiting."
      exit 1
    fi
    # Iterate through Pods to check health
    healthy=true
    for pod in "${PODS[@]}"; do
      cmd="kubectl logs $pod -n ${namespace} --tail=0"
      if [[ $last_attempt == true ]]; then
        node=$(kubectl get pod $pod -n $namespace -o jsonpath='{.spec.node.Name}')
        echo "Checking node: $node"
        if ! ${cmd}; then
          healthy=false
        else
          echo "OK"
        fi
      else
        if ! ${cmd} &> /dev/null; then
          healthy=false
        fi
    done

    if [[ $healthy == "false" ]]; then
      return 1
    fi

    return 0

}

counter=0
number_retries=40
retry_wait_time=60

echo "Running script to ensure kube master can communicate with all worker nodes."

while [ ${counter} -le ${number_retries} ]; do
  last_attempt=false
  if [ "${counter}" -eq "${number_retries}" ]; then
    last_attempt=true
  fi
  
  ((counter=counter+1))

  if run_checks ${last_attempt}; then
    break
  else
    if [ ${counter} -gt ${number_retries} ]; then
      echo "Maximum attempts reached: Giving up."
      echo
      echo "Found Kube master is UNABLE to communicate with one or more worker nodes."
      echo "Please create a support issue"
      exit 1
    else
      echo "Retrying in ${retry_wait_time}s. (Retry Attempt: ${counter} / ${number_retries})"
      sleep ${retry_wait_time}
  fi
done

echo "Success! Master can communicate with all Worker Nodes."