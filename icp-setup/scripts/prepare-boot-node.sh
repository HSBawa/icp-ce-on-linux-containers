#!/bin/bash
#############################################################################
## This script prepares boot node for ICP Installation
#############################################################################
INSTALL_PROPERTIES="./install.properties"
CLUSTER_PROPERTIES="./cluster.properties"


VMS=()
BOOT_ICP_DIR=""
BOOT_ICP_CLUSTER_DIR=""
BOOT_ICP_BIN_DIR=""
BOOT_ICP_LOG_DIR=""
BOOT_VM=""
DOWNLOAD_CLIS_FILE_TMPL=""
MASTER_IP="10.50.50.101"
DOWNLOAD_CLIS_FILE="./download_icp_cloudctl_helm.sh"
ICP_LOGIN_SH_FILE_TMPL=""
BOOT_NODE_GREP_KEY="master"
BOOT_ICP_DOCKER_IMAGE=""
BOOT_ICP_DOCKER_IMAGE_LOCAL=""
ICP_LOGIN_SH_FILE=""
SSH_KEYS_FOLDER=""
CLUSTER_FOLDER=""
ROUTER_KEYS_FOLDER=""
BOOT_ICP_CFC_CERTS_DIR=""
NFS_VM=""


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

function  initialize(){
  SSH_KEYS_FOLDER="${ICP_SETUP_FOLDER}/ssh-keys"
  CLUSTER_FOLDER="${ICP_SETUP_FOLDER}/cluster"
  ROUTER_KEYS_FOLDER="${ICP_SETUP_FOLDER}/router-certs"
  DOWNLOAD_CLIS_FILE_TMPL="${ICP_SETUP_FOLDER}/scripts/tmpl/download-icp-cloudctl-helm.sh.tmpl"
  ICP_LOGIN_SH_FILE_TMPL="${ICP_SETUP_FOLDER}/scripts/tmpl/icp-login.sh.tmpl"
  BOOT_NODE_GREP_KEY="${ICP_MASTER_NAME}"
  VMS=($(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv))
  BOOT_ICP_DIR="/opt/icp-${ICP_TAG}-${ICP_EDITION}"
  BOOT_ICP_CLUSTER_DIR="$BOOT_ICP_DIR/cluster"
  BOOT_ICP_CFC_CERTS_DIR="${BOOT_ICP_CLUSTER_DIR}/cfc-certs/router"
  BOOT_ICP_BIN_DIR="$BOOT_ICP_DIR/bin"
  BOOT_ICP_LOG_DIR="$BOOT_ICP_DIR/log"
  BOOT_VM="${ICP_ENV_NAME_SHORT}-${ICP_MASTER_NAME}-0"
  BOOT_NODE_GREP_KEY=${ICP_MASTER_NAME}
  BOOT_ICP_DOCKER_IMAGE="/share/${ICP_DOCKER_IMG}"
  BOOT_ICP_DOCKER_IMAGE_LOCAL="/media/lxcshare/${ICP_DOCKER_IMG}"
  ICP_LOGIN_SH_FILE=./icp-login-${ICP_TAG}-${ICP_EDITION}.sh
  MASTER_IP=$(lxc exec  ${BOOT_VM} -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
  echo "$MASTER_IP"
}

function get_boot_vm_name(){
    BOOT_VM="$(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv | grep $BOOT_NODE_GREP_KEY)"
    echo "Boot VM is: $BOOT_VM"
    MASTER_IP=$(lxc exec  $BOOT_VM -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
}

function setup_inception_image(){
    echo "Checking if ${BOOT_ICP_DOCKER_IMAGE_LOCAL} exists"
    if [[ -f ${BOOT_ICP_DOCKER_IMAGE_LOCAL} ]] && [[ ${ICP_USE_DOCKER_IMG} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
      lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ${BOOT_ICP_DOCKER_IMAGE_LOCAL} $BOOT_VM/$BOOT_ICP_CLUSTER_DIR/images/${ICP_DOCKER_IMG}
      load_icp_docker_image
    else
      echo "Pulling ${ICP_INSTALLER}:${ICP_TAG}"
      lxc exec $BOOT_VM -- sh -c "docker pull ${ICP_INSTALLER}:${ICP_TAG}"
    fi
}

function fix_loop_issue(){
    lxc exec ${BOOT_VM} -- sh -c "sed -i 's/nameserver 127.0.0.1/#nameserver 127.0.0.1/g' /etc/resolv.conf"
}

function copy_config_files(){
    lxc exec $BOOT_VM -- mkdir -p $BOOT_ICP_CLUSTER_DIR
    lxc exec $BOOT_VM -- mkdir -p /root/cluster/
    lxc exec $BOOT_VM -- mkdir -p $BOOT_ICP_BIN_DIR
    lxc exec $BOOT_VM -- mkdir -p $BOOT_ICP_LOG_DIR
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ${CLUSTER_FOLDER}/config.yaml $BOOT_VM/root/cluster/config.yaml
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ${CLUSTER_FOLDER}/hosts $BOOT_VM/root/cluster/hosts
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ${SSH_KEYS_FOLDER}/id_rsa $BOOT_VM/root/.ssh/id_rsa
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ${SSH_KEYS_FOLDER}/id_rsa.pub $BOOT_VM/root/.ssh/id_rsa.pub
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ${CLUSTER_FOLDER}/install.sh $BOOT_VM$BOOT_ICP_BIN_DIR/install.sh
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ${CLUSTER_FOLDER}/install-dbg.sh $BOOT_VM$BOOT_ICP_BIN_DIR/install-dbg.sh
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ${CLUSTER_FOLDER}/uninstall.sh $BOOT_VM$BOOT_ICP_BIN_DIR/uninstall.sh

    echo "$BOOT_ICP_CLUSTER_DIR"
    echo "lxc exec $BOOT_VM -- sh -c \"cp /root/cluster/config.yaml $BOOT_ICP_CLUSTER_DIR/config.yaml\""
    lxc exec $BOOT_VM -- sh -c  "cp /root/.ssh/id_rsa $BOOT_ICP_CLUSTER_DIR/ssh_key"
    lxc exec $BOOT_VM -- sh -c "cp /root/cluster/hosts $BOOT_ICP_CLUSTER_DIR/hosts"
    lxc exec $BOOT_VM -- sh -c "cp /root/cluster/config.yaml $BOOT_ICP_CLUSTER_DIR/config.yaml"
    lxc exec $BOOT_VM -- sh -c "ls -al $BOOT_ICP_CLUSTER_DIR"
    if [[ ${ICP_USE_ROUTER_KEY} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
      echo "$(ls -al ${ROUTER_KEYS_FOLDER})"
      lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ${ROUTER_KEYS_FOLDER}/icp-router.crt $BOOT_VM/${BOOT_ICP_CFC_CERTS_DIR}/icp-router.crt
      lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ${ROUTER_KEYS_FOLDER}/icp-router.key $BOOT_VM/${BOOT_ICP_CFC_CERTS_DIR}/icp-router.key
      lxc exec $BOOT_VM -- sh -c "ls -al $BOOT_ICP_CFC_CERTS_DIR"
      echo "To replace certificates after install: https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/user_management/byok_certs.html"
    fi

}

function prepare_nfs_server(){
  NFS_VM="$(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv | grep ${NFS_NAME})"
  echo "Your NFS VM is: $NFS_VM"
  for (( i = 1; i <= ${NFS_INITIAL_VOLUME_COUNT}; i++ )); do
    NFS_VOL=${NFS_DEVICE_SOURCE}/vol${i}
    if [[ ! -d ${NFS_VOL} ]]; then
      mkdir -p ${NFS_VOL}
    fi
    if [[ ${i} == 1 ]]; then
      lxc exec $NFS_VM -- sh -c "echo \"${NFS_DEVICE_PATH}/vol${i}   *(rw,sync,no_root_squash,no_subtree_check,insecure)\" > /etc/exports"
    else
      lxc exec $NFS_VM -- sh -c "echo \"${NFS_DEVICE_PATH}/vol${i}   *(rw,sync,no_root_squash,no_subtree_check,insecure)\" >> /etc/exports"
    fi
  done
  lxc exec $NFS_VM -- exportfs -a
}

function extract_configuration_data(){
  echo "Extracting configuration data ..."
    if [[ -f ${BOOT_ICP_DOCKER_IMAGE_LOCAL} ]] && [[ ${ICP_USE_DOCKER_IMG} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
      lxc exec $BOOT_VM -- sh -c "docker run -e LICENSE=accept -v $BOOT_ICP_DIR:/data $ICP_INSTALLER:${ICP_TAG}-${ICP_EDITION} cp -r cluster /data"

    else
      lxc exec $BOOT_VM -- sh -c "docker run -e LICENSE=accept -v $BOOT_ICP_DIR:/data $ICP_INSTALLER:${ICP_TAG} cp -r cluster /data"
    fi
  sleep 10
  lxc exec $BOOT_VM -- sh -c "ls -al $BOOT_ICP_CLUSTER_DIR"
}


function load_icp_docker_image(){
    echo ">>>>>>>>>>>>>>>>>>>>>>>>> Loading ${BOOT_ICP_DOCKER_IMAGE} on ${BOOT_VM} <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    lxc exec ${BOOT_VM} -- sh -c "tar xf ${BOOT_ICP_DOCKER_IMAGE} -O | sudo docker load"
}


function create_cli_download_script(){
    sed  's/@@MASTER_NODE@@/'"$BOOT_VM"'/g' <$DOWNLOAD_CLIS_FILE_TMPL >$DOWNLOAD_CLIS_FILE
}

function create_icp_login_script(){
    sed -e 's|@@ICP_DEFAULT_ADMIN_USER@@|'"${ICP_DEFAULT_ADMIN_USER}"'|g' \
        -e 's|@@ICP_DEFAULT_ADMIN_PASSWORD@@|'"${ICP_DEFAULT_ADMIN_PASSWORD}"'|g' \
        -e 's|@@ICP_CLUSTER_NAME@@|'"${ICP_CLUSTER_NAME}"'|g' \
        -e 's|@@MASTER_NODE_IP@@|'"${MASTER_IP}"'|g' \
        -e 's|@@ICP_DEFAULT_NAMESPACE@@|'"${ICP_DEFAULT_NAMESPACE}"'|g' < "${ICP_LOGIN_SH_FILE_TMPL}" > "${ICP_LOGIN_SH_FILE}"
}


function run_install(){
    TAG_EDITION=${ICP_TAG}
    rm "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null
    rm "${HOME}/ICP_LXD_INSTALL_SUCCESS" &> /dev/null
    rm "${HOME}/ICP_LXD_INSTALL_FAILURE" &> /dev/null
    touch "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null
    if [[ -f ${BOOT_ICP_DOCKER_IMAGE_LOCAL} ]] && [[ ${ICP_USE_DOCKER_IMG} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
      ICP_TAG_EDITION=${ICP_TAG}-${ICP_EDITION}
    fi
    if [[ $install_dbg == "1" ]]; then
        echo "Running install in debug mode"
        lxc exec $BOOT_VM -- sh -c "$BOOT_ICP_BIN_DIR/install-dbg.sh $BOOT_ICP_CLUSTER_DIR ${ICP_INSTALLER} ${ICP_TAG_EDITION} $BOOT_ICP_LOG_DIR"
    else
        echo "Running install in non-debug mode"
        lxc exec $BOOT_VM -- sh -c "$BOOT_ICP_BIN_DIR/install.sh $BOOT_ICP_CLUSTER_DIR ${ICP_INSTALLER} ${ICP_TAG_EDITION} $BOOT_ICP_LOG_DIR"
    fi

    success=$?
    if [ $success -eq 0 ]; then
	      rm "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null
        touch "${HOME}/ICP_LXD_INSTALL_SUCCESS" &> /dev/null
        pod_check_interval=20
        echo ""
        echo ">>>>>>>>>>>>>>>[ICP installation was success]"
        if [[ ${ICP_TAG} =~ ^("3.1.2"|"3.2.0")$ ]]; then
            echo ">>>>>>>>>>>>>>>>>>Creating shell script ($DOWNLOAD_CLIS_FILE) to download: cloudctl, helm and kubectl<<<<<<<<<<<<<<<<<<"
            create_cli_download_script
            echo ""
            echo ">>>>>>>>>>>>>>>>>Creating helper login script for your login ease <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            create_icp_login_script
            echo "Login helper script (**contains password**): ${ICP_LOGIN_SH_FILE}"
            echo "Done"
            echo ""
        fi
   	### for some reason non-sudo command is not working
        echo ""
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
        echo "|*|*|*|*|*|*|*|*|*| |I|n|s|t|a|l|l| |C|o|m|p|l|e|t|e| |*|*|*|*|*|*|*|*|*|*|*|*|"
        echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
        echo "+-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+ +-+-+-+"
        echo "|I|C|P| |o|n| |L|i|n|u|x| |C|o|n|t|a|i|n|e|r|s| |i|s| |r|e|a|d|y| |t|o| |u|s|e|"
        echo "+-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+ +-+-+-+"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    else
	rm "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null
        touch "${HOME}/ICP_LXD_INSTALL_FAILURE" &> /dev/null
        echo ""
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!INSTALL FAILED - $success !!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

    fi

}

read_properties
initialize
echo ">>>>>>>>>>>>>>>[Retrieving boot node information ...] "
get_boot_vm_name
echo "Boot Node name is: $BOOT_VM"
echo ""
echo ">>>>>>>>>>>>>>>[Fix loop on $BOOT_VM ...]"
fix_loop_issue
echo ""
if [[ ${NFS_NODE} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
  echo ">>>>>>>>>>>>>>>[Preparing NFS Server ...]"
  prepare_nfs_server
  echo ""
fi
echo ">>>>>>>>>>>>>>>[Setting up inception image on $BOOT_VM ...] "
setup_inception_image
echo ""
echo ">>>>>>>>>>>>>>>[Extracting configuration data  ...] "
extract_configuration_data
echo ""
echo ">>>>>>>>>>>>>>>[Copying config file to $BOOT_VM for installation  ...] "
copy_config_files
echo ""
echo ">>>>>>>>>>>>>>>[Starting ICP install on $BOOT_VM ...] "
run_install
echo ""
