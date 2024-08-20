#!/bin/bash

# Function to check if the oc command is available
function check_oc() {
    if ! command -v oc &>/dev/null; then
        echo "oc command not found. Please install the oc CLI tool."
        exit 1
    fi
}

# Function to wait for the operator deployment object to be ready
function wait_for_deployment() {
    local deployment=$1
    local namespace=$2
    local timeout=300
    local interval=5
    local elapsed=0
    local ready=0

    while [ $elapsed -lt $timeout ]; do
        ready=$(oc get deployment -n "$namespace" "$deployment" -o jsonpath='{.status.readyReplicas}')
        if [ "$ready" == "1" ]; then
            echo "Operator $deployment is ready"
            return 0
        fi
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    echo "Operator $deployment is not ready after $timeout seconds"
    return 1
}

# Function to apply the operator manifests
function apply_operator_manifests() {
    
    # Apply the manifests, error exit if any of them fail
    if [[ $CLUSTER == "OCP" ]] then
      oc apply -f ns.yaml || exit 1
      oc apply -f kbs_catalog-ocp.yaml || exit 1
      oc apply -f og.yaml || exit 1
      oc apply -f subs-ocp.yaml || exit 1
    else
      echo "This is not OCP cluster"
      exit 1      
    fi
}

# Function to create keys
function create_keys() {
    # create keys
    curl https://people.redhat.com/eesposit/key.bin -o key.bin || exit 1
    openssl genpkey -algorithm ed25519 > privateKey || exit 1
    openssl pkey -in privateKey -pubout -out kbs.pem || exit 1
    oc create secret generic kbs-auth-public-key --from-file=kbs.pem -n kbs-operator-system || exit 1
    oc apply -f reference-values.yaml || exit 1
    oc create secret generic kbsres1 --from-literal key1=res1val1 --from-literal key2=res1val2 key.bin=key.bin -n kbs-operator-system || exit 1
    oc apply -f kbs-config.yaml || exit 1
    oc apply -f crd.yaml || exit 1
}

# Function to get a key from kbs server
function get_kbs_key() {
    namespace="kbs-operator-system"

    #start a kbs client pod
    oc apply -f kbsclient-tdx.yaml || exit 1
    sleep 30
    kbsclient_pod=$(oc get pod kbs-client -n default -o jsonpath='{.status.phase}')
    if [ $kbsclient_pod == "running" ];then
      echo "kbs client pod is runing"
    else
      echo "kbs pod not running"||exit 1
    fi
    
    #Get the kbs deployment and operator pods status
    kbs_pod_stats_num=$(oc get pod -n $namespace -o jsonpath="{range .items[*]}[{.metadata.name},{.status.phase}]{'\n'}{end}"|grep -Ei "kbs*.*running"|wc -l)
    if [ $kbs_pod_stats_num -eq 2 ]; then
      KBS_SVC_IP=$(oc get svc -n kbs-operator-system kbs-service -o jsonpath={.spec.clusterIP}) || exit 1
      #oc set image -n kbs-operator-system deployment/kbs-deployment kbs=quay.io/openshift_sandboxed_containers/kbs:latest || exit 1
      oc set image -n kbs-operator-system deployment/kbs-deployment kbs=quay.io/openshift_sandboxed_containers/kbs:tdx-hack || exit 1
      oc exec -it kbs-client -- kbs-client --url http://$KBS_SVC_IP:8080 get-resource --path default/kbsres1/key1 || exit 1
    else 
      echo "kbs deployment/operator pods not runnig" || exit 1
    fi
}
