#!/bin/bash

source ./helper.sh

# Function to check if the container can start with kata-cc-tdx
function start_container_tdx() {
    local deployment=$1
    local namespace=$2
    local timeout=300
    local interval=5
    local elapsed=0

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

# Check if oc is available
check_oc

# Check if the cluster kubeconfig is exported
check_kubeconfig

# Start container with kata-cc-tdx runtimeClassName
start_container_tdx test-kata-cc-tdx default

# Clean the container
clean_container test-kata-cc-tdx default
