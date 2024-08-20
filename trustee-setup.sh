#!/bin/bash

CLUSTER="${CLUSTER:-OCP}"

source ./common.sh

# Check if oc command is available
check_oc

# Apply the operator manifests
apply_operator_manifests $CLUSTER 

# Create keys for kbs operator
create_keys

wait_for_deployment trustee-operator-controller-manager kbs-operator-system || exit 1
wait_for_deployment trustee-deployment kbs-operator-system || exit 1
