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
ICP_BOOT_IMG_LXCSHARE="/media/lxcshare/icp-ce-3.1.2-boot.tar.gz"
ICP_BOOT_IMG="/share/icp-ce-3.1.2-boot.tar.gz"
ICP_MASTER_IMG="/share/icp-ce-3.1.2-master.tar.gz"
ICP_COMMON_WORKER_IMG="/share/icp-ce-3.1.2-common-worker.tar.gz"
ICP_PROXY_IMG="/share/icp-ce-3.1.2-proxy.tar.gz"
ICP_LOGIN_SH_FILE=""
SSH_KEYS_FOLDER=""
CLUSTER_FOLDER=""


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
  DOWNLOAD_CLIS_FILE_TMPL="${ICP_SETUP_FOLDER}/scripts/tmpl/download-icp-cloudctl-helm.sh.tmpl"
  ICP_LOGIN_SH_FILE_TMPL="${ICP_SETUP_FOLDER}/scripts/tmpl/icp-login.sh.tmpl"
  BOOT_NODE_GREP_KEY="${ICP_MASTER_NAME}"
  VMS=($(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv))
  BOOT_ICP_DIR="/opt/icp-${ICP_TAG}-${ICP_EDITION}"
  BOOT_ICP_CLUSTER_DIR="$BOOT_ICP_DIR/cluster"
  BOOT_ICP_BIN_DIR="$BOOT_ICP_DIR/bin"
  BOOT_ICP_LOG_DIR="$BOOT_ICP_DIR/log"
  BOOT_VM="${ICP_ENV_NAME_SHORT}-${ICP_MASTER_NAME}-0"
  BOOT_NODE_GREP_KEY=${ICP_MASTER_NAME}
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
    echo "Checking if $ICP_BOOT_IMG_LXCSHARE exists"
    if [[ ! -f $ICP_BOOT_IMG_LXCSHARE ]]; then
       echo "$ICP_BOOT_IMG_LXCSHARE does not exists"
       echo "Pulling ${ICP_INSTALLER}:${ICP_TAG}"
       lxc exec $BOOT_VM -- sh -c "docker pull ${ICP_INSTALLER}:${ICP_TAG}"
    else
       load_docker_archives
    fi
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
}

function extract_configuration_data(){
  echo "Extracting configuration data ..."
  lxc exec $BOOT_VM -- sh -c "docker run -e LICENSE=accept -v $BOOT_ICP_DIR:/data $ICP_INSTALLER:${ICP_TAG} cp -r cluster /data"
  sleep 10
  lxc exec $BOOT_VM -- sh -c "ls -al $BOOT_ICP_CLUSTER_DIR"
}

function load_docker_archives(){
    echo ">>>>>>>>>>>>>>>>>>>>>>>>> Loading ICP Docker Images for all VMS<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    for index in ${!VMS[*]}
    do
        vm=${VMS[$index]}
        ## Update VM /etc/hosts file
        case "$vm" in
             *master*)
                 echo "Loading ICP Docker images for Master Node: "
                 lxc exec $vm -- sh -c "docker load -i $ICP_BOOT_IMG" &> /dev/null
                 lxc exec $vm -- sh -c "docker load -i $ICP_COMMON_WORKER_IMG" &> /dev/null
                 lxc exec $vm -- sh -c "docker load -i $ICP_MASTER_IMG" &> /dev/null
                 ;;
             *proxy*)
                 echo "Loading ICP Docker images for Proxy Node: "
                 lxc exec $vm -- sh -c "docker load -i $ICP_COMMON_WORKER_IMG" &> /dev/null
                 lxc exec $vm -- sh -c "docker load -i $ICP_PROXY_IMG" &> /dev/null
                 ;;
             *worker*)
                 echo "Loading ICP Docker images for Worker Node: "
                 lxc exec $vm -- sh -c "docker load -i $ICP_COMMON_WORKER_IMG" &> /dev/null
                 ;;
         esac
    done
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
    rm "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null
    rm "${HOME}/ICP_LXD_INSTALL_SUCCESS" &> /dev/null
    rm "${HOME}/ICP_LXD_INSTALL_FAILURE" &> /dev/null
    touch "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null

    if [[ $install_dbg == "1" ]]; then
        echo "Running install in debug mode"
        lxc exec $BOOT_VM -- sh -c "$BOOT_ICP_BIN_DIR/install-dbg.sh $BOOT_ICP_CLUSTER_DIR ${ICP_INSTALLER} ${ICP_TAG} $BOOT_ICP_LOG_DIR"
    else
        echo "Running install in non-debug mode"
        lxc exec $BOOT_VM -- sh -c "$BOOT_ICP_BIN_DIR/install.sh $BOOT_ICP_CLUSTER_DIR ${ICP_INSTALLER} ${ICP_TAG} $BOOT_ICP_LOG_DIR"
    fi

    success=$?
    if [ $success -eq 0 ]; then
	      rm "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null
        touch "${HOME}/ICP_LXD_INSTALL_SUCCESS" &> /dev/null
        pod_check_interval=20
        echo ""
        echo ">>>>>>>>>>>>>>>[ICP installation was success]"
        if [[ ${ICP_TAG} =~ ^("3.1.1"|"3.1.2")$ ]]; then
            echo ">>>>>>>>>>>>>>>>>>Creating shell script ($DOWNLOAD_CLIS_FILE) to download: cloudctl, helm and kubectl<<<<<<<<<<<<<<<<<<"
            create_cli_download_script
            echo ""
            echo ">>>>>>>>>>>>>>>>>Creating helper login script for your login ease <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            create_icp_login_script
            cat ${ICP_LOGIN_SH_FILE}
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
