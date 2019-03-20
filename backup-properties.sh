#!/bin/bash

##############################################################################
# backup_properties.sh
##############################################################################

INSTALL_PROPERITES="./install.properties"
BACKUP_FOLDER=""
CLUSTER_FOLDER=""
SSH_KEYS_FOLDER=""
ROUTER_CRT_FOLDER=""
PLAN_FOLDER=""


function  read_properties() {
  while IFS== read -r KEY VALUE
  do
      if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
        export "$KEY=$VALUE"
      fi
  done < ${INSTALL_PROPERITES}
}

function initialize(){
  BACKUP_FOLDER="${PROPERTIES_BACKUP_FOLDER}/$(date +%Y%m%d_%H%M%S)"
  CLUSTER_FOLDER="${ICP_SETUP_FOLDER}/cluster"
  SSH_KEYS_FOLDER="${ICP_SETUP_FOLDER}/ssh-keys"
  ROUTER_CRT_FOLDER="${ICP_SETUP_FOLDER}/router-certs"
  PLAN_FOLDER="${ICP_SETUP_FOLDER}/plan"
}


function is_root(){
  if [[ $EUID -ne 0 ]]; then
    echo "Create cluster script (./backup_properties.sh) must be run as 'root' user"
    echo "Sudoer may or may not work, depending upon its configuration"
    echo "Suggestion: sudo su -"
    echo "            cd ${PWD}"
    echo "            ./backup_properties.sh "
    echo ""
    echo "Exiting. Please try again."
    exit 1
  fi
}

function backup() {
    if [[ ! -d "${BACKUP_FOLDER}" ]]; then
      sudo mkdir -p ${BACKUP_FOLDER}/.terraform
    fi

    if [[ "$?" -eq 0 ]]; then
      echo "Copying files to folder: ${BACKUP_FOLDER}"
      sudo cp install.properties                      ${BACKUP_FOLDER}
      sudo cp -R .terraform                           ${BACKUP_FOLDER}/.terraform
      sudo cp terraform.tfstate                       ${BACKUP_FOLDER}
      sudo cp ${PLAN_FOLDER}/icp-on-lxc-plan.txt      ${BACKUP_FOLDER}
      sudo cp ${CLUSTER_FOLDER}/config.yaml           ${BACKUP_FOLDER}
      sudo cp ${CLUSTER_FOLDER}/etc-hosts             ${BACKUP_FOLDER}
      sudo cp ${CLUSTER_FOLDER}/hosts                 ${BACKUP_FOLDER}
      sudo cp ${CLUSTER_FOLDER}/ssh_key               ${BACKUP_FOLDER}
      sudo cp ${SSH_KEYS_FOLDER}/id_rsa               ${BACKUP_FOLDER}
      sudo cp ${SSH_KEYS_FOLDER}/id_rsa.pub           ${BACKUP_FOLDER}
      sudo cp ${ROUTER_CRT_FOLDER}/icp-router.crt     ${BACKUP_FOLDER}
      sudo cp ${ROUTER_CRT_FOLDER}/icp-router.key     ${BACKUP_FOLDER}
      sudo ls -al ${BACKUP_FOLDER}
      echo "Done"
      echo ""
    else
      echo "ERROR!!! Error creating backup folder: ${BACKUP_FOLDER}. Please try again. Exiting"
      exit -1
    fi
}

is_root
read_properties
initialize
backup
