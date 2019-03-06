#!/bin/bash

###############################################################################
## This programs initiates ICP on CE installation process using terraform
##   a) Create one of the following cluster of LXD nodes for IBM Cloud Private - Community Edition (ICP-CE)
##       1) 1 Master - n Worker nodes architecture
##       2) 1 Master, 1 Proxy, 1 Management and n Worker node(s) architecture
##   b) Install ICP-CE installation on cluster of LXD nodes
## @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################

IS_MINIMAL_INSTALL="0"
HOST_IP_ADDRESS=""
INSTALL_PROPERTIES="./install.properties"

MAIN_TF_TMPL_NAME=""
MAIN_TF_FILE_NAME=""
PROXY_TF_TMPL_NAME=""
MGMT_TF_TMPL_NAME=""
TFVARS_TMPL_NAME=""
TFVARS_FILE_NAME=""
TERRA_PLAN_FOLDER=""
TERRRA_WORK_FOLDER=""


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

function initialize(){
  MAIN_TF_TMPL_NAME="./${ICP_SETUP_FOLDER}/main.tf.tmpl"
  MAIN_TF_FILE_NAME="./${ICP_SETUP_FOLDER}/main.tf"
  PROXY_TF_TMPL_NAME="./${ICP_SETUP_FOLDER}/proxy.tf.tmpl"
  MGMT_TF_TMPL_NAME="./${ICP_SETUP_FOLDER}/mgmt.tf.tmpl"
  TFVARS_TMPL_NAME="./${ICP_SETUP_FOLDER}/terraform.tfvars.tmpl"
  TFVARS_FILE_NAME="./${ICP_SETUP_FOLDER}/terraform.tfvars"
  VARS_FILE_NAME="./${ICP_SETUP_FOLDER}/variables.tf"
  TERRA_PLAN_FOLDER="./${ICP_SETUP_FOLDER}/plan"
  TERRA_WORK_FOLDER="./${ICP_SETUP_FOLDER}"
}



function validate_image_exist(){
  IMAGE_EXISTS="$(lxc image list | grep ${ICP_LXD_IMAGE_NAME})"
  if [[ -z ${IMAGE_EXISTS} ]]; then
    echo "******************************************************************************************"
    echo "ERROR: Cannot proceed as LXD Image - ${ICP_LXD_IMAGE_NAME} - does not exists. Exiting"
    echo "******************************************************************************************"
    exit
  fi
}

function check_for_existing_lxd_components(){
  if [[ ! -z ${ICP_ENV_NAME_SHORT} ]]; then
      env=${ICP_ENV_NAME_SHORT}
      vms="$(lxc list ${env}- -c n --format=csv)"
      profiles="$(lxc profile list | grep ${env} | awk '{print $2}')"
      networks="$(lxc network list | grep ${env} | awk '{print $2}')"

      if [[ ! -z ${vms} ]] || [[ ! -z ${profiles} ]]  || [[ ! -z ${networks} ]]; then
        echo "Seems like some stale components exist."
        if [[ ! -z "${vms}" ]]; then
          echo "   Containers: $vms"
        fi
        if [[ ! -z  ${profiles} ]]; then
          echo "   Profile: $profiles"
        fi

        if [[ ! -z ${networks} ]]; then
          echo "   Networks: $networks"
        fi

        if [[ "${LXD_AUTO_DESTROY_OLD_CLUSTER_COMPONENTS} =~ ^([yY][eE][sS]|[yY])+$ " ]]; then
          echo "Deleting ..."
          for vm in ${vms[*]}
          do
            lxc stop -f $vm ; lxc delete -f $vm
          done
          echo ""

          for profile in ${profiles[*]}
          do
            lxc profile delete $profile
          done
          echo ""

          for network in ${networks[*]}
          do
            lxc network delete $network
          done
          echo "Done."
          echo ""
        else
          echo "To delete these components, following are two options: "
          echo "   'cd icp-setup' then run script: 'destroy-cluster-manual.sh' "
          echo "   set 'LXD_AUTO_DESTROY_OLD_CLUSTER_COMPONENTS=y' in 'install.properties' and run 'install.sh' again."
        fi
      fi
  fi
}

function get_ip_address() {
  ## Mostly VM Devices with internal and public ip address
  if [[  "${LXD_HOST}" =~ ^(vsi|fyre|aws|othervm)+$ ]]; then
    HOST_IP_ADDRESS="$(hostname -I | cut -d' ' -f2)"
  elif [[ "${LXD_HOST}" =~ ^(pc)+$ ]]; then
    HOST_IP_ADDRESS="$(hostname -I | cut -d' ' -f1)"
  else
    HOST_IP_ADDRESS="none"
  fi
}

####################################################################################
##  This function is workaround for the terrform plugin snap path issue.
##  This issue may have been addressed in the new lxd terraform plugin.
##  Update the code as needed later.
####################################################################################
function select_right_unix_socket_address(){
  local APT_UNIX_SOCKET_ADDRESS="/var/lib/lxd/unix.socket"
  local SNAP_UNIX_SOCKET_ADDRESS="/var/snap/lxd/common/lxd/unix.socket"
  local UNIX_SOCKET_ADDRESS="@@UNIX_SOCKET_ADDRESS@@"
  local lxc_loc="$(which lxc)"

  if [[  -z lxc_loc  ]]; then
     echo "LXC binary not found. Exiting"
     exit;
  fi

  sed -i "s|@@LXD_CORE_HTTPS_PORT@@|$LXD_CORE_HTTPS_PORT|g"         $MAIN_TF_FILE_NAME
  sed -i "s|@@LXD_CORE_TRUST_PASSWORD@@|$LXD_CORE_TRUST_PASSWORD|g" $MAIN_TF_FILE_NAME

  if echo "$lxc_loc" | grep -q "snap"; then
      echo "Updating Socket Adderess to SNAP"
      sed -i "s|$UNIX_SOCKET_ADDRESS|$SNAP_UNIX_SOCKET_ADDRESS|g" $MAIN_TF_FILE_NAME
  else
      echo "Updating Socket Adderess to APT"
      sed -i "s|$UNIX_SOCKET_ADDRESS|$APT_UNIX_SOCKET_ADDRESS|g" $MAIN_TF_FILE_NAME
  fi

}

function initialize_tfvars(){

  sed -e 's|@@ICP_ENV_NAME_LONG@@|'"${ICP_ENV_NAME_LONG}"'|g' \
      -e 's|@@ICP_ENV_NAME_SHORT@@|'"${ICP_ENV_NAME_SHORT}"'|g' \
      -e 's|@@ICP_ENV_NAME_DESC@@|'"${ICP_ENV_NAME_DESC}"'|g' \
      -e 's|@@ICP_INSTALL_DEBUG@@|'"${ICP_INSTALL_DEBUG}"'|g' \
      -e 's|@@ICP_LXD_IMAGE_NAME@@|'"${ICP_LXD_IMAGE_NAME}"'|g' \
      -e 's|@@ICP_TAG@@|'"${ICP_TAG}"'|g' \
      -e 's|@@ICP_EDITION@@|'"${ICP_EDITION}"'|g' \
      -e 's|@@ICP_INSTALLER@@|'"${ICP_INSTALLER}"'|g' \
      -e 's|@@ICP_IPV4_CIDR_PREFIX@@|'"${ICP_IPV4_CIDR_PREFIX}"'|g' \
      -e 's|@@ICP_IPV6_CIDR_PREFIX@@|'"${ICP_IPV6_CIDR_PREFIX}"'|g' \
      -e 's|@@ICP_IPV4_NAT@@|'"${ICP_IPV4_NAT}"'|g' \
      -e 's|@@ICP_IPV6_NAT@@|'"${ICP_IPV6_NAT}"'|g' \
      -e 's|@@ICP_NW_NAME_MIDFIX@@|'"${ICP_NW_NAME_MIDFIX}"'|g' \
      -e 's|@@ICP_NW_DEVICE_NAME@@|'"${ICP_NW_DEVICE_NAME}"'|g' \
      -e 's|@@ICP_NW_DEVICE_TYPE@@|'"${ICP_NW_DEVICE_TYPE}"'|g' \
      -e 's|@@ICP_NW_NIC_TYPE@@|'"${ICP_NW_NIC_TYPE}"'|g' \
      -e 's|@@ICP_COMMON_PROFILE_NAME@@|'"${ICP_COMMON_PROFILE_NAME}"'|g' \
      -e 's|@@ICP_MASTER_NAME@@|'"${ICP_MASTER_NAME}"'|g' \
      -e 's|@@ICP_PROXY_NAME@@|'"${ICP_PROXY_NAME}"'|g' \
      -e 's|@@ICP_MGMT_NAME@@|'"${ICP_MGMT_NAME}"'|g' \
      -e 's|@@ICP_WORKER_NAME@@|'"${ICP_WORKER_NAME}"'|g' \
      -e 's|@@ICP_MASTER_STORAGE_DEVICE_NAME@@|'"${ICP_MASTER_STORAGE_DEVICE_NAME}"'|g' \
      -e 's|@@ICP_WORKER_STORAGE_DEVICE_NAME@@|'"${ICP_WORKER_STORAGE_DEVICE_NAME}"'|g' \
      -e 's|@@ICP_PROXY_STORAGE_DEVICE_NAME@@|'"${ICP_PROXY_STORAGE_DEVICE_NAME}"'|g' \
      -e 's|@@ICP_MGMT_STORAGE_DEVICE_NAME@@|'"${ICP_MGMT_STORAGE_DEVICE_NAME}"'|g' \
      -e 's|@@ICP_MASTER_STORAGE_DEVICE_SIZE@@|'"${ICP_MASTER_STORAGE_DEVICE_SIZE}"'|g' \
      -e 's|@@ICP_WORKER_STORAGE_DEVICE_SIZE@@|'"${ICP_WORKER_STORAGE_DEVICE_SIZE}"'|g' \
      -e 's|@@ICP_PROXY_STORAGE_DEVICE_SIZE@@|'"${ICP_PROXY_STORAGE_DEVICE_SIZE}"'|g' \
      -e 's|@@ICP_MGMT_STORAGE_DEVICE_SIZE@@|'"${ICP_MGMT_STORAGE_DEVICE_SIZE}"'|g' \
      -e 's|@@ICP_MASTER_STORAGE_DEVICE_PATH@@|'"${ICP_MASTER_STORAGE_DEVICE_PATH}"'|g' \
      -e 's|@@ICP_WORKER_STORAGE_DEVICE_PATH@@|'"${ICP_WORKER_STORAGE_DEVICE_PATH}"'|g' \
      -e 's|@@ICP_PROXY_STORAGE_DEVICE_PATH@@|'"${ICP_PROXY_STORAGE_DEVICE_PATH}"'|g' \
      -e 's|@@ICP_MGMT_STORAGE_DEVICE_PATH@@|'"${ICP_MGMT_STORAGE_DEVICE_PATH}"'|g' \
      -e 's|@@ICP_MASTER_STORAGE_DEVICE_TYPE@@|'"${ICP_MASTER_STORAGE_DEVICE_TYPE}"'|g' \
      -e 's|@@ICP_WORKER_STORAGE_DEVICE_TYPE@@|'"${ICP_WORKER_STORAGE_DEVICE_TYPE}"'|g' \
      -e 's|@@ICP_PROXY_STORAGE_DEVICE_TYPE@@|'"${ICP_PROXY_STORAGE_DEVICE_TYPE}"'|g' \
      -e 's|@@ICP_MGMT_STORAGE_DEVICE_TYPE@@|'"${ICP_MGMT_STORAGE_DEVICE_TYPE}"'|g' \
      -e 's|@@ICP_MASTER_CPU_COUNT@@|'"${ICP_MASTER_CPU_COUNT}"'|g' \
      -e 's|@@ICP_PROXY_CPU_COUNT@@|'"${ICP_PROXY_CPU_COUNT}"'|g' \
      -e 's|@@ICP_MGMT_CPU_COUNT@@|'"${ICP_MGMT_CPU_COUNT}"'|g' \
      -e 's|@@ICP_WORKER_CPU_COUNT@@|'"${ICP_WORKER_CPU_COUNT}"'|g' \
      -e 's|@@ICP_MASTER_START_HOST_IP@@|'"${ICP_MASTER_START_HOST_IP}"'|g' \
      -e 's|@@ICP_PROXY_START_HOST_IP@@|'"${ICP_PROXY_START_HOST_IP}"'|g' \
      -e 's|@@ICP_MGMT_START_HOST_IP@@|'"${ICP_MGMT_START_HOST_IP}"'|g' \
      -e 's|@@ICP_WORKER_START_HOST_IP@@|'"${ICP_WORKER_START_HOST_IP}"'|g' \
      -e 's|@@ICP_MASTER_NODE_COUNT@@|'"${ICP_MASTER_NODE_COUNT}"'|g' \
      -e 's|@@ICP_PROXY_NODE_COUNT@@|'"${ICP_PROXY_NODE_COUNT}"'|g' \
      -e 's|@@ICP_MGMT_NODE_COUNT@@|'"${ICP_MGMT_NODE_COUNT}"'|g' \
      -e 's|@@ICP_WORKER_NODE_COUNT@@|'"${ICP_WORKER_NODE_COUNT}"'|g' \
      -e 's|@@ICP_MASTER_POOL_NAME@@|'"${ICP_MASTER_POOL_NAME}"'|g' \
      -e 's|@@ICP_PROXY_POOL_NAME@@|'"${ICP_PROXY_POOL_NAME}"'|g' \
      -e 's|@@ICP_MGMT_POOL_NAME@@|'"${ICP_MGMT_POOL_NAME}"'|g' \
      -e 's|@@ICP_WORKER_POOL_NAME@@|'"${ICP_WORKER_POOL_NAME}"'|g' < ${TFVARS_TMPL_NAME} > ${TFVARS_FILE_NAME}

}


##### TEMP ONLY FOR TESTING
function terra_clean(){
    echo "Deleting terraform states"
    rm -rf ./.terraform  &> /dev/null
    rm ./terraform.tfstate  &> /dev/null
    rm ./terraform.tfstate.backup  &> /dev/null
    rm ${TERRA_PLAN_FOLDER}/*.txt  &> /dev/null
}


function start_banner(){
     echo ""
     echo ""
     echo "+-+-+-+-+-+-+-+ +-+-+ +-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+"
     echo "|W|e|l|c|o|m|e| |t|o| |I|C|P| |o|n| |L|i|n|u|x| |C|o|n|t|a|i|n|e|r|s|"
     echo "---------------------------------------------------------------------"
     echo "|           |H|a|r|i|m|o|h|a|n| |S| |B|a|w|a|                       |"
     echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
     echo ""
     echo ""
}

function start_install(){
    mkdir -p /media/lxcshare &> /dev/null
    chmod +x ${ICP_SETUP_FOLDER}/scripts/*.sh
    mkdir -p ${TERRA_PLAN_FOLDER} &> /dev/null

    cp $MAIN_TF_TMPL_NAME $MAIN_TF_FILE_NAME &> /dev/null

    select_right_unix_socket_address

    if [[ ${PROXY_NODE} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cat ${PROXY_TF_TMPL_NAME} | tee -a ${MAIN_TF_FILE_NAME}   &> /dev/null
    fi

    if [[ ${MGMT_NODE} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        cat  ${MGMT_TF_TMPL_NAME}  | tee -a ${MAIN_TF_FILE_NAME}   &> /dev/null
    fi


    ## Start installation
    echo ""
    echo "Initializing terraform"
    terraform init ${TERRA_WORK_FOLDER}
    echo ""
    echo "Creating terraform plan"
    terraform plan -var-file=${TFVARS_FILE_NAME} -out=${TERRA_PLAN_FOLDER}/icp-on-lxc-plan.txt ${TERRA_WORK_FOLDER}
    echo ""
    echo "Applying terraform plan"
    terraform apply ${TERRA_PLAN_FOLDER}/icp-on-lxc-plan.txt
}

### CLEANUP
rm "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null
rm "${HOME}/ICP_LXD_INSTALL_SUCCESS" &> /dev/null
rm "${HOME}/ICP_LXD_INSTALL_FAILED" &> /dev/null
touch "${HOME}/ICP_LXD_INSTALL_STARTED" &> /dev/null

### START INSTALL
read_properties
initialize
check_for_existing_lxd_components
validate_image_exist
get_ip_address
terra_clean
initialize_tfvars
start_banner
start_install
