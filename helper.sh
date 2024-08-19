#!/bin/bash

PUBKEY_PATH=~/.ssh/id_rsa.pub
WORKER_NODE="worker"

# Function to check if the oc command is available
function check_oc() {
    if ! command -v oc &>/dev/null; then
        echo "oc command not found. Please install the oc CLI tool."
        exit 1
    fi
}

# Check if kubeconfig is exported
function check_kubeconfig() {
    if ! oc get nodes &>/dev/mull; then
        echo "Fails to login the cluster. Please import the cluster kubeconfig."
        exit 1
    fi
}


# Function to get the worker node name
function get_worker_node(){
    WORKER_NODE=$(oc get nodes -o=custom-columns=NAME:.metadata.name | sed 1d)
    echo $WORKER_NODE
}

# Function to check and uploads local server ssh public key to the worker node
function uploads_ssh_pubkey(){
    if ! ls $PUBKEY_PATH; then
        echo "Local server ssh public key patch doesn't exists. Please enter the correct path"
        read -p "Please enter your local server ssh public key path: " PUBKEY_PATH
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

# Function to disable the SeLinux
function disbale_selinux_worker(){
    ssh core@$WORKER_NODE <<EOF
sudo su -
cat /etc/redhat-release
uname -a
setenforce 0
exit
exit
EOF
}

# Function to clean container
function clean_container(){
    local deployment=$1
    local namespace=$2
    oc delete pod $deployment -n $namespace || oc delete pod $deployment -n $namespace --force 
}
