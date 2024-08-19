#!/bin/bash

# Function to start container which will collect tdx td quote
function start_container_evidence_getter() {
    local deployment=$1
    local namespace=$2
    local timeout=300
    local interval=5
    local elapsed=0
    local podname=evidence-getter
    local namespace=default

    oc apply -f evidence-getter.yaml || exit 1

    while [ $elapsed -lt $timeout ]; do
        status=$(oc get pods -n "$namespace" "$deployment" -o jsonpath='{.status.phase}')
	echo "The container is $status"
        if [ "$status" == "Running" ]; then
            echo "The evidence getter container with kata-cc-tdx can start up"
            return 0
        fi
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    echo "The evidence getter container with kata-cc-tdx fails start up after $timeout seconds"
    return 1
}

# Function to get evidence
function get_evidence(){
    local podname=evidence-getter
    local namespace=default
    evidence=$(oc exec -it $podname -n $namespace -- sh -c "dd if=/dev/urandom bs=64 | evidence_getter")
    quote=$(echo "$content" | jq ".quote")
    echo $quote
    if [ ! -z "$quote" ]; then
       echo "Get tdx quote successfully"
    else
	echo "Fails to get tdx quote. Please check the qgs and pccs service."
	exit 1
    fi
}

# Start container to get td quote
start_container_evidence_getter evidence-getter default

# Get td quote
get_evidence evidence-getter default 
