#!/bin/bash

INSTALL_PROPERTIES="./install.properties"

vms=()
vm_ips=()
master="[master]"
proxy="[proxy]"
mgmt="[management]"
va="[va]"
worker="[worker]"
CLUSTER_FOLDER=""

function read_properties(){
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
  CLUSTER_FOLDER="${ICP_SETUP_FOLDER}/cluster"
  vms=($(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv))
  echo ${vms}
  array_size=${#vms[*]}
  if [[ "$array_size" -eq 0  ]]; then
    echo "Invalid VM count: ${array_size}. Exiting."
    exit -1
  fi
}

################################################################################
## Create hosts file for install
################################################################################

function create_etc_hosts_file(){
    echo ""                                                                        | tee -a ${CLUSTER_FOLDER}/hosts  &> /dev/null
    echo "#### Auto-generated file"                                                | tee -a ${CLUSTER_FOLDER}/hosts  &> /dev/null
    echo "127.0.0.1 localhost"                                                     | tee ${CLUSTER_FOLDER}/etc-hosts &> /dev/null
    for index in ${!vms[*]}
    do
        vm=${vms[$index]}
        vm_ips[$index]=$(lxc exec  ${vms[$index]} -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
        ## Update VM /etc/hosts file
        echo ${vm_ips[$index]} $vm                                                 | tee -a ${CLUSTER_FOLDER}/etc-hosts &> /dev/null
        case "$vm" in
             *master*)
                 master="$master ${vm_ips[$index]}"
                 #mgmt_exists=$(lxc list ${env}- -c n --format=csv | grep mgmt)
                 #if [[ -z "${mgmt_exists}" ]]; then
                 #   echo "Mgmt does not exists"
                 #fi
                 ## Check in advance if  proxy and management nodes exists or not and use master for them.
                 proxy_exists=$(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv | grep ${ICP_PROXY_NAME})
                 if [[ -z "${proxy_exists}" ]]; then
                     proxy="$proxy ${vm_ips[$index]}"
                 fi
                 mgmt_exists=$(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv | grep ${ICP_MGMT_NAME})
                 if [[ -z "${mgmt_exists}" ]]; then
                     mgmt="$mgmt ${vm_ips[$index]}"
                 fi
                 ;;
             *proxy*)
                 proxy="$proxy ${vm_ips[$index]}"
                 ;;
             *mgmt*)
                 mgmt="$mgmt ${vm_ips[$index]}"
                 ;;
             *va*)
                 va="$va ${vm_ips[$index]}"
                 ;;
             *worker*)
                 worker="$worker ${vm_ips[$index]}"
                 ;;
         esac
    done
    echo ""
    echo "#######################################################################" | tee    ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo "##                  !!!!WARNING!!!!                                    " | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo "##             This file is auto-generated.                            " | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo "##  Any updates will be overwritten in next setup/install process      " | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo "#######################################################################" | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo ""                                                                        | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo "$master" | tr ' ' '\n'                                                   | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo ""                                                                        | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo "$proxy" | tr ' ' '\n'                                                    | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo ""                                                                        | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo "$mgmt" | tr ' ' '\n'                                                     | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo ""                                                                        | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null
    echo "$worker" | tr ' ' '\n'                                                   | tee -a ${CLUSTER_FOLDER}/hosts &> /dev/null

    echo "${CLUSTER_FOLDER}/etc-hosts"
    cat ${CLUSTER_FOLDER}/etc-hosts
    echo ""
    echo "${CLUSTER_FOLDER}/hosts"
    cat ${CLUSTER_FOLDER}/hosts
}

################################################################################
## Function to preserve original hosts file for each VM. Call seperately
################################################################################
function dummy(){
    for vm in ${vms[*]}
    do
         lxc exec $vm -- sh -c "cp /etc/hosts /etc/hosts.orig"
    done
}
################################################################################
## Copy hosts file to each VM
################################################################################
function copy_etc_hosts_file(){
    for vm in ${vms[*]}
    do
        lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ${CLUSTER_FOLDER}/etc-hosts $vm/etc/hosts
    done
}

read_properties
initialize
echo ">>>>>>>>>>>>>>>[Creating hosts file for VMs... ]"
create_etc_hosts_file
echo ""
echo ">>>>>>>>>>>>>>>[Copying hosts file to all VMs... ]"
copy_etc_hosts_file
echo ""
