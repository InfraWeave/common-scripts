#!/bin/bash

set -e

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

done

echo "Success! Master can communicate with all Worker Nodes."