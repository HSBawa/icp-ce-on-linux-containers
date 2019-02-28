#!/bin/bash


MASTER_VM="dev-master-0"
IP_ADDRESS="10.50.50.101"

###########################################################
## Make sure to replace "eth0" with right network device. 
###########################################################
function get_host_ext_ip(){
   IP_ADDRESS="$(ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
}

function set_master_vm(){
   if [[ ! -z "$1"  ]]; then
      MASTER_VM="$1"
   fi
}

function add_or_remove_cluster_access(){
  if [[ "y" == "$1"  ]]; then
    echo "Adding cluster access URL"
    lxc exec ${MASTER_VM} -- sh -c "/opt/icp-3.1.0-ce/bin/clusteraccessurl.sh ${IP_ADDRESS}"
  elif [[ "n" == "$1"  ]]; then
    echo "Removing cluster access URL"
    lxc exec ${MASTER_VM} -- sh -c "/opt/icp-3.1.0-ce/bin/removeclusteraccessurl.sh ${IP_ADDRESS}"
  else
     echo "Invalid enable disable option: $1"
     echo "add_or_remove_cluster_access.sh <yY|nN> [master-vm-name] ## 'y' to add ,  'n' to remove cluster access, dev-master-0 is default master vm name" 
  fi
}

get_host_ext_ip
set_master_vm $2
echo "Master VM : ${MASTER_VM}"
add_or_remove_cluster_access $1
