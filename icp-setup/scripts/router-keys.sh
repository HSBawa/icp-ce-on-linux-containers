#!/bin/bash

INSTALL_PROPERTIES="./install.properties"
CLUSTER_PROPERTIES="./cluster.properties"

ROUTER_KEYS_FOLDER=""
VMS=()

function  read_properties(){
  if [[ -f "${INSTALL_PROPERTIES}" ]]; then
    while IFS== read -r KEY VALUE
    do
        if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
          export "$KEY=$VALUE"
        fi
    done < ${INSTALL_PROPERTIES}
  else
    echo "Missing install properties file ${INSTALL_PROPERTIES}. Exiting now."
    exit -1
  fi
}

function  initialize(){
  ICP_ROUTER_CERTS_FOLDER="${ICP_SETUP_FOLDER}/router-certs"
  VMS=($(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv))
}

function update_router_cert_key(){
  if [[ -f "${ICP_ROUTER_CRT_FILE}" ]] && [[ -f "${ICP_ROUTER_KEY_FILE}" ]]; then
    echo ">>>>>>>>>>>>>>>[Copying router crt and key files to ${ICP_ROUTER_CERTS_FOLDER} ... ]"
    echo ""
    cp ${ICP_ROUTER_CRT_FILE} ${ICP_ROUTER_CERTS_FOLDER}/icp-router.crt
    cp ${ICP_ROUTER_KEY_FILE} ${ICP_ROUTER_CERTS_FOLDER}/icp-router.key
    echo "ICP_CLUSTER_CA_DOMAIN=${ICP_ROUTER_CA_DOMAIN}" >> ${CLUSTER_PROPERTIES}
    echo ""
  else
    echo "No id_rsa found in ${SSH_KEYS_FOLDER} folder. Installation will fail. Exiting."
    exit -1
  fi
  echo ""
}

read_properties
initialize
update_router_cert_key
