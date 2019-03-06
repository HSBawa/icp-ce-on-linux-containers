#!/bin/bash

INSTALL_PROPERTIES="./install.properties"

SSH_KEYS_FOLDER=""
CLUSTER_FOLDER=""
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
  SSH_KEYS_FOLDER="${ICP_SETUP_FOLDER}/ssh-keys"
  CLUSTER_FOLDER="${ICP_SETUP_FOLDER}/cluster"
  VMS=($(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv))
}

function update_ssh(){
  echo ">>>>>>>>>>>>>>>[Generating SSH RSA keys for ${ICP_ENV_NAME_SHORT}-icp-${ICP_TAG}-${ICP_EDITION}-on-lxc... ]"
  echo ""
  echo "y" | /usr/bin/ssh-keygen -t rsa -b 4096 -f ${SSH_KEYS_FOLDER}/id_rsa -N '' -C "${ICP_ENV_NAME_SHORT}-icp-${ICP_TAG}-${ICP_EDITION}-on-lxc"
  cp ${SSH_KEYS_FOLDER}/id_rsa ${CLUSTER_FOLDER}/ssh_key
  echo ""
  echo ">>>>>>>>>>>>>>>[Updating SSH authorized_key on VMS ... ]"
  echo ""
  for VM in ${VMS[*]}
  do
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ${SSH_KEYS_FOLDER}/id_rsa.pub ${VM}/root/.ssh/authorized_keys
  done
}

read_properties
initialize
update_ssh
