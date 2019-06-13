#!/bin/bash

INSTALL_PROPERTIES="./install.properties"
SCRIPTS_FOLDER=""

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

function initialize() {
  SCRIPTS_FOLDER="${ICP_SETUP_FOLDER}/scripts"
}

function pre_install_config(){

    if [[ ${SETUP_HAPROXY_ICP} =~ ^([yY][eE][sS]|[yY])+$  ]] && [[ ${INSTALL_HAPROXY} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        sudo ${SCRIPTS_FOLDER}/haproxy-cfg.sh
    fi

    if [[ ${ICP_USE_ROUTER_KEY} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
        sudo ${SCRIPTS_FOLDER}/router-keys.sh
    fi

    ## VM Performance tuning
    source ${SCRIPTS_FOLDER}/lxd-node-opt.sh

    ## Back up the existing configuration
    source ${SCRIPTS_FOLDER}/backup.sh

    ## Create SSH Keys
    source ${SCRIPTS_FOLDER}/ssh-keys.sh

    ## Update Config File
    source ${SCRIPTS_FOLDER}/config-update.sh

    ## Create Hosts file and update VMs /etc/hosts file
    ## TODO: Fix issue passing multiple arrays (vm names and their ips)
    source ${SCRIPTS_FOLDER}/create-hosts-file.sh

    ## Create for VM root size
    source ${SCRIPTS_FOLDER}/check-root-size.sh
}

function install(){
  ## Prepare boot node and start install
  #echo "Executing: source ${SCRIPTS_FOLDER}/prepare-boot-node.sh"
  source ${SCRIPTS_FOLDER}/prepare-boot-node.sh

  ##################################
  ## RUN ONLY IF INSTALL WAS SUCCESS
  ##################################

  success="$(ls ${HOME} | grep SUCCESS )"
  echo "Success value: $success"

  if [[ ! -z "$success"  ]];then
    ## Configure Docker CLU Authentication for ICP and Requires ROOT access
    source ${SCRIPTS_FOLDER}/configure-docker-cli.sh
  fi

}

read_properties
initialize
#pre_install_config
#install
