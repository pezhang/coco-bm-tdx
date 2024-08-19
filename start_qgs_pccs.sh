#!/bin/bash

export API_KEY=""

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

udpate_api_key
copy_tdx_folder
start_qgs_pccs_container
