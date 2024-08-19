#!/bin/bash

source ./helper.sh

# Function to check and uploads local server ssh public key to the worker node
function uploads_ssh_pubkey(){
    if ! ls $PUBKEY_PATH; then
        echo "Local server ssh public key patch doesn't exists. Please export PUBKEY_PATH with correct path"
        exit 1
    fi
    PUBKEY=$(cat $PUBKEY_PATH)
    echo $PUBKEY
    oc debug  node/$worker_node <<EOF
    chroot /host
    if ! grep "$PUBKEY" /home/core/.ssh/authorized_keys; then
      echo "${PUBKEY}" >> /home/core/.ssh/authorized_keys
    fi
    exit
    exit
EOF
}

# Get worker node
get_worker_node

# Uploads local server ssh pulic key to the worker node
uploads_ssh_pubkey

# Disable SeLinux of worker node
disbale_selinux_worker
