#!/bin/bash

##############################################################################
# install.sh
# Reads install.properties file for new variables or variable override.
# Variable names keep in upper case (or starts with upper case)
# IMPORTANT: Chnage "CORE_TRUST_PASSWORD" in install.properties before this
#            script is executed
##############################################################################

TERRA_LXD_PLUGIN_LOC="${HOME}/.terraform.d/plugins/linux_amd64"

LXD_PACKER_TMPL_NAME=./lxd-setup/tmpl/packer-lxd-image-lvm-bionic.tmpl
LXD_PACKER_FILE_NAME=./lxd-setup/gen/packer-lxd-image-lvm-bionic


function  read_properties() {
  while IFS== read -r KEY VALUE
  do
      if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
        export "$KEY=$VALUE"
      fi
  done < ./install.properties
}

function initialize(){
  echo ""
  echo "Initializing environment ... "
  echo ""
  echo "   Running apt-get update ..."
  echo ""
  sudo apt-get update &> /dev/null

  if [[ ${LXD_HOST} =~ ^([aA][wW][sS])+$  ]]; then
    sudo apt-add-repository 'deb http://us-east-2.ec2.archive.ubuntu.com/ubuntu/ bionic-updates main restricted' &> /dev/null
    sudo apt-add-repository 'deb http://us-east-2.ec2.archive.ubuntu.com/ubuntu/ bionic universe' &> /dev/null
    sudo apt-add-repository 'deb http://us-east-2.ec2.archive.ubuntu.com/ubuntu/ bionic-updates universe' &> /dev/null
    sudo apt-add-repository 'deb http://us-east-2.ec2.archive.ubuntu.com/ubuntu/ bionic multiverse' &> /dev/null
    sudo apt-add-repository 'deb http://us-east-2.ec2.archive.ubuntu.com/ubuntu/ bionic-updates multiverse' &> /dev/null
    sudo apt-add-repository 'deb http://us-east-2.ec2.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse' &> /dev/null
    sudo apt-get update &> /dev/null
  fi

  if [[ ! -z  " ${UPDATE_LINUX_IMAGE}" ]] && [[ ${UPDATE_LINUX_IMAGE} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
    if [[ ${LXD_HOST} =~ ^([aA][wW][sS])+$  ]]; then
      echo "   Updating image: linux-image-$(uname -r) linux-image-extra-virtual"
      echo ""
      sudo apt install -y linux-image-$(uname -r) linux-modules-extra-$(uname -r) linux-image-extra-virtual &> /dev/null
    else
      echo "   Updating image: linux-image-$(uname -r) linux-modules-extra-$(uname -r) linux-image-extra-virtual"
      echo ""
      sudo apt install -y linux-image-$(uname -r) linux-modules-extra-$(uname -r) linux-image-extra-virtual &> /dev/null
    fi
  fi

  if [[ ! -z "${UBUNTU_PACKAGES_TO_INSTALL}" ]]; then
      echo "   Installing packages: ${UBUNTU_PACKAGES_TO_INSTALL} ..."
      echo ""
      sudo apt install -y ${UBUNTU_PACKAGES_TO_INSTALL} &> /dev/null
  fi

  if [[ ! -z "${HAPROXY_PACKAGE_TO_INSTALL}" ]] &&  [[ ${INSTALL_HAPROXY} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
      echo "   Installing packages: '${HAPROXY_PACKAGE_TO_INSTALL}' ..."
      echo ""
      sudo apt install -y ${HAPROXY_PACKAGE_TO_INSTALL} &> /dev/null
  fi

  echo "   Updating/Installing packages: lxd and client ..."
  echo ""
  sudo apt install -y lxd lxd-client &> /dev/null


  echo "   Creating folder : /media/lxcshare"
  sudo mkdir -p  /media/lxcshare
  echo "Done"
  echo ""
  echo "Waiting for system to settle down ..."
  sleep 10
  echo ""
}

function lxd_init(){
   LXD_LOC="$(which lxd)"
   if [[ -z "${LXD_LOC}"  ]]; then
     echo "***********************************************************************"
     echo "Seems like LXD is not installed. Please validate and run install again."
     echo "***********************************************************************"
     echo ""
     exit
   fi
   LXD_VERSION="$(lxd version)"

   if [[ "3.0.3" != "${LXD_VERSION}" ]]; then
     echo "*******************************************************************"
     echo "Unsupported LXD version. Your installation may not work"
     echo "*******************************************************************"
     echo ""
   fi

  if [[ ${INIT_LXD} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
    STORAGE_EXISTS="$(lxc storage list | grep ${LXD_PROFILE_N_POOL_NAME})"
    NETWORK_EXISTS="$(lxc network list | grep ${LXD_NW_NAME})"
    PROFILE_EXISTS="$(lxc profile list | grep ${LXD_PROFILE_N_POOL_NAME})"
    echo "lxc config set core.https_address \"${LXD_CORE_HTTPS_IP}:${LXD_CORE_HTTPS_PORT}\""
    echo "lxc config set core.trust_password ${LXD_CORE_TRUST_PASSWORD}"
    lxc config set core.https_address "${LXD_CORE_HTTPS_IP}:${LXD_CORE_HTTPS_PORT}"
    lxc config set core.trust_password ${LXD_CORE_TRUST_PASSWORD}

    if [[ -z ${STORAGE_EXISTS} ]] || [[ -z ${NETWORK_EXISTS} ]] || [[ -z ${PROFILE_EXISTS} ]]; then
      if [[ -z ${STORAGE_EXISTS} ]]; then
        LXD_POOL_SIZE_SOURCE_LABEL="${LXD_POOL_SIZE_LABEL}"
        LXD_POOL_SIZE_SOURCE_VALUE="${LXD_POOL_SIZE}"
        if [[  ${LXD_POOL_USE_DEVICE} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            LXD_POOL_SIZE_SOURCE_LABEL="${LXD_POOL_SOURCE_LABEL}"
            LXD_POOL_SIZE_SOURCE_VALUE="${LXD_POOL_DEVICE}"
        fi
        lxc storage create ${LXD_PROFILE_N_POOL_NAME} ${LXD_POOL_DRIVER} ${LXD_POOL_SIZE_SOURCE_LABEL}=${LXD_POOL_SIZE_SOURCE_VALUE}
      fi

      if [[ -z ${NETWORK_EXISTS} ]]; then
        lxc network create ${LXD_NW_NAME} ipv4.address=${LXD_NW_IPV4_ADDRESS} ipv4.nat=${LXD_NW_IPV4_NAT} ipv6.address=${LXD_NW_IPV6_ADDRESS} ipv6.nat=${LXD_NW_IPV6_NAT}
      fi

      if [[ -z ${PROFILE_EXISTS} ]]; then
        lxc profile create ${LXD_PROFILE_N_POOL_NAME}
      fi
      STORAGE_EXISTS="$(lxc storage list | grep ${LXD_PROFILE_N_POOL_NAME})"
      NETWORK_EXISTS="$(lxc network list | grep ${LXD_NW_NAME})"
      PROFILE_EXISTS="$(lxc profile list | grep ${LXD_PROFILE_N_POOL_NAME})"

      if [[ -z ${STORAGE_EXISTS} ]]; then
        echo "ERROR!!! - LXD storage ${LXD_PROFILE_N_POOL_NAME} was not successfully created."
      fi

      if [[ ! -z ${PROFILE_EXISTS} ]]; then
        lxc profile device add ${LXD_PROFILE_N_POOL_NAME} root disk path=/ pool=${LXD_PROFILE_N_POOL_NAME} size=${LXD_DEVICE_ROOT_SIZE}
      else
        echo "ERROR!!! - LXD profile ${LXD_PROFILE_N_POOL_NAME} was not successfully created."
        exit -5
      fi

      if [[ ! -z ${NETWORK_EXISTS} ]]; then
        lxc network attach-profile ${LXD_NW_NAME} ${LXD_PROFILE_N_POOL_NAME} eth0 eth0
      else
        echo "ERROR!!! - LXD network ${LXD_NW_NAME} was not successfully created."
        exit -5
      fi
      echo "Waiting for system to settle down ..."
      sleep 10
      echo ""
    else
        echo "This LXD configuration already exists. Either delete it first or provide different configuration."
        echo "Continuing with existing configuration."
        echo ""
    fi
  fi
}

function create_lxd_image_for_icp(){
  EXISTS="$(lxc image list | grep ${ICP_LXD_IMAGE_NAME})"
  if [[ ${LXD_OVERWRITE_EXISTING_IMAGE} =~ ^([yY][eE][sS]|[yY])+$ ]] ||  [[ -z ${EXISTS} ]]; then
    if [[ -f "${LXD_PACKER_TMPL_NAME}" ]]; then
      packer=$(which packer)
      if [[ ! -z  "${packer}" ]]; then

        if [[ ${LXD_HOST}  =~ ^([aA][wW][sS])+$ ]]; then
          LXD_PACKER_TMPL_NAME=./lxd-setup/tmpl/packer-lxd-image-lvm-bionic-for-aws.tmpl
          LXD_PACKER_FILE_NAME=./lxd-setup/gen/packer-lxd-image-lvm-bionic-for-aws
        fi
        sed -e 's|@@ICP_LXD_IMAGE_NAME@@|'"${ICP_LXD_IMAGE_NAME}"'|g' \
            -e 's|@@LXD_BASE_IMAGE_NAME@@|'"${LXD_BASE_IMAGE_NAME}"'|g' \
            -e 's|@@ICP_LXD_IMAGE_PUB_DESC@@|'"${ICP_LXD_IMAGE_PUB_DESC}"'|g' \
            -e 's|@@ICP_LXD_PROFILE_NAME@@|'"${LXD_PROFILE_N_POOL_NAME}"'|g' < ${LXD_PACKER_TMPL_NAME} > ${LXD_PACKER_FILE_NAME}

        eval ${packer} validate ${LXD_PACKER_FILE_NAME}
        eval ${packer} build    ${LXD_PACKER_FILE_NAME}
      else
        echo "Missing packer executable. Exiting."
        echo ""
        exit -1
      fi
      sleep 5
      IMAGE_CREATED="$(lxc image list | grep ${ICP_LXD_IMAGE_NAME})"
      if [[ -z ${IMAGE_CREATED} ]]; then
        echo "ERROR!!! ${ICP_LXD_IMAGE_NAME} Image creation failed."
        echo ""
        delete_lxd_components delete_storage
        exit -5
      else
        echo "Image ${ICP_LXD_IMAGE_NAME} was successfully created."
        echo ""
        delete_lxd_components
      fi
    else
      echo "Missing packer image template file:${PACKER_TMPL_NAME} . Exiting."
      echo ""
      exit -1
    fi
  else
    echo ""
    echo "LXD Image ${ICP_LXD_IMAGE_NAME} already exists and overwrite is disabled. Skipping image creation process."
    echo "To create new image, either delete existing image or set OVERWRITE_EXISTING_IMAGE=y"
    echo ""
  fi
}

function delete_lxd_components(){

  ### Delete NW and Profile - No longer needed
  lxc network delete ${LXD_NW_NAME}
  echo ""
  lxc profile delete ${LXD_PROFILE_N_POOL_NAME}
  echo ""
  if [[ "delete_storage" == "${1}" ]]; then
    lxc storage delete ${LXD_NW_NAME}
    echo ""
  fi
}

read_properties
initialize
lxd_init
create_lxd_image_for_icp
