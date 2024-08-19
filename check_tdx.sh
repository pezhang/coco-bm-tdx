#!/bin/bash

# Function to check if the container can start with kata-cc-tdx
function start_container_tdx() {
    local deployment=$1
    local namespace=$2
    local timeout=300
    local interval=5
    local elapsed=0
    local podname=test-kata-cc-tdx
    local namespace=default

    oc apply -f kata-cc-tdx.yaml || exit 1

    while [ $elapsed -lt $timeout ]; do
        status=$(oc get pods -n "$namespace" "$deployment" -o jsonpath='{.status.phase}')
	echo "The container is $status"
        if [ "$status" == "Running" ]; then
            echo "The container with kata-cc-tdx can start up"
            return 0
        fi
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    echo "The container with kata-cc-tdx fails start up after $timeout seconds"
    return 1
}

start_container_tdx test-kata-cc-tdx test
