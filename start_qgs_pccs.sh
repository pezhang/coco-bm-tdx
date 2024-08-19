#!/bin/bash

source ./helper.sh

API_KEY=""
REGISTER=no

# Read API key from stdin
function read_api_key(){
    read -p "Enter your API key(Ref: https://api.portal.trustedservices.intel.com): " API_KEY
}

# Function to check if API key exists
function udpate_api_key() {
    default_config_file="tdx/config/default.json"
    if ! API_KEY; then
        echo "API_KEY is empty, please export the corret API_KEY from https://api.portal.trustedservices.intel.com"
	exit 1
    else
	jq '.ApiKey = "$API_KEY"' <<<"$default_config_file"
    fi
}

# Function to copy the tdx folder to worker node
function copy_tdx_folder(){
    scp -r tdx core@WORKER_NODE:/home/core/
}

# Function to register the system, only needs to be performed once per system
function register_system(){
    read -p "Have your system registered? yes or no " REGISTER
    if REGISTER=no; then 
        echo "The system will not be registered as you set REGISTER as no. If your system is not registered yet, please set the REGISTER=yes"
	exit 0
    fi
    ssh core@$WORKER_NODE <<EOF
sudo su -
cat /etc/redhat-release
uname -a
podman exec -it sgx-pck-id-retrieval-tool bash
cd /opt/intel/sgx-ra-service/ && ./mpa_registration
cd /opt/intel/sgx-pck-id-retrieval-tool  && ./PCKIDRetrievalTool -f /backup/ppip.csv
exit
exit
EOF
}

# Function to startup qgs and pccs containers
function start_qgs_pccs_container() {
    ssh core@$WORKER_NODE <<EOF
sudo su -
cat /etc/redhat-release
uname -a
sh /home/core/tdx/run-containers.sh
podman ps
exit
exit
EOF
}

# Function to load the vsock_loopback
function load_vsock_loopback_worker(){
    ssh core@$WORKER_NODE <<EOF
sudo su -
cat /etc/redhat-release
uname -a
lsmod | grep vsock_loopback || modprobe vsock_loopback
exit
exit
EOF
}

# Get worker node
get_worker_node

# User input the API Key
read_api_key

# Update the API Key
udpate_api_key

# Copy tdx foler which includes qgs and pccs setup/config etc
copy_tdx_folder

# start qgs and pccs service 
start_qgs_pccs_container

# Load vsock_loopback on the worker node
load_vsock_loopback_worker

# Register your system
register_system
