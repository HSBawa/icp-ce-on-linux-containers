#!/bin/bash
#############################################################################
# Clone secret from one namespace to other
# clone-secret.sh <SOURCE_SECRET_NAME> <SOURCE_NAMESPACE> <TARGET_NAMESPACE>
#############################################################################

SOURCE_SECRET_NAME=$1
SOURCE_NAMESPACE=$2
TARGET_NAMESPACE=$3

function clone_secret(){
    echo "Cloning secret ${SOURCE_SECRET_NAME} from namespace ${SOURCE_NAMESPACE} to ${TARGET_NAMESPACE} ... "
    kubectl get secret ${SOURCE_SECRET_NAME} --namespace=${SOURCE_NAMESPACE} --export -o yaml | kubectl apply --namespace=${TARGET_NAMESPACE} -f -
    kubectl get secret ${SOURCE_SECRET_NAME} --namespace=${TARGET_NAMESPACE}
}

function validate_parameters(){
    if [[ "$#" -ne 3 ]]; then
        echo "Illegal number of parameters"
        exit -1;
    fi    
}

validate_parameters
clone_secret
