#!/bin/bash

INSTALL_PROPERTIES="./install.properties"

function  read_properties() {
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

function backup(){
    SSH_KEYS_FOLDER="${ICP_SETUP_FOLDER}/ssh-keys"
    CLUSTER_FOLDER="${ICP_SETUP_FOLDER}/cluster"

    echo ">>>>>>>>>>>>>>>[Backing up SSH Keys on local host ... ]"
    if [[ -f "${SSH_KEYS_FOLDER}/id_rsa" ]]; then
      mv ${SSH_KEYS_FOLDER}/id_rsa ${SSH_KEYS_FOLDER}/id_rsa.bak &> /dev/null
    fi
    
    if [[ -f "${SSH_KEYS_FOLDER}/id_rsa.pub" ]]; then
      mv ${SSH_KEYS_FOLDER}/id_rsa.pub ${SSH_KEYS_FOLDER}/id_rsa.pub.bak &> /dev/null
    fi
    echo ""

    echo ">>>>>>>>>>>>>>>[Backing up hosts file on local host ... ]"
    if [[ -f "${CLUSTER_FOLDER}/hosts" ]]; then
      mv ${CLUSTER_FOLDER}/hosts ${CLUSTER_FOLDER}/hosts.bak &> /dev/null
    fi
    echo ""

    echo ">>>>>>>>>>>>>>>[Backing up etc-hosts file on local host ... ]"
    if [[ -f "${CLUSTER_FOLDER}/etc-hosts" ]]; then
      mv ${CLUSTER_FOLDER}/etc-hosts ${CLUSTER_FOLDER}/etc-hosts.bak &> /dev/null
    fi
    echo ""

    echo ">>>>>>>>>>>>>>>[Backing up config file on local host ... ]"
    if [[ -f "${CLUSTER_FOLDER}/etc-hosts" ]]; then
      mv ${CLUSTER_FOLDER}/config.yaml ${CLUSTER_FOLDER}/config.yaml.bak &> /dev/null
    fi
    echo ""
}

read_properties
backup
