#!/bin/bash

source ./helper.sh

# Function to check if the git command is available
function check_git() {
    if ! command -v git &>/dev/null; then
        echo "git command not found. Please install the git tool."
        exit 1
    fi
}

# Function to clone the repo
function clone_osc_install(){
    local osc_install_repo=$1
    local osc_path=$2
    git clone $osc_install_repo $osc_path || exit 1
}

# Function to install the coco
function install_coco(){
    local osc_path=$1
    cd $osc_path && ./install.sh || exit 1
}

# Check if git is available
check_git

# Check if oc is available
check_oc

# Check if the cluster kubeconfig is exported
check_kubeconfig

# Clone the CoCo installation repo
clone_osc_install https://gitlab.cee.redhat.com/prbanerj/osc-install.git osc-install

# Install CoCo operator
install_coco osc-install

