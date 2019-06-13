#!/bin/bash
#############################################################################
## This script prepares boot node for ICP Installation
#############################################################################
INSTALL_PROPERTIES="./install.properties"
CLUSTER_PROPERTIES="./cluster.properties"





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

  if [[ -f "${CLUSTER_PROPERTIES}" ]]; then
    while IFS== read -r KEY VALUE
    do
        if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
          export "$KEY=$VALUE"
        fi
    done < ${CLUSTER_PROPERTIES}
  else
    echo "Missing cluster properties file ${CLUSTER_PROPERTIES}. Exiting now."
    exit -1
  fi

}

function prepare_nfs_server(){
  if [[ ${NFS_NODE} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    for (( i = 1; i <= ${NFS_INITIAL_VOLUME_COUNT}; i++ )); do
      NFS_VOL=${NFS_DEVICE_SOURCE}/vol${i}
      if [[ ! -d ${NFS_VOL} ]]; then
        echo "mkdir -p ${NFS_VOL}"
        mkdir -p ${NFS_VOL}
      fi
    done
  fi

}

read_properties
initialize
prepare_nfs_server
