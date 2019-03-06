#!/bin/bash
################################################################################
## This script will optimize VM nodes
################################################################################

INSTALL_PROPERTIES="./install.properties"
vms=()
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
  vms=($(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv))
}


function optimize_vms(){
    for vm in ${vms[*]}
    do
        echo "$vm"
        lxc exec $vm -- sh -c "echo 'fs.inotify.max_queued_events = 1048576' | tee --append /etc/sysctl.conf"         &> /dev/null
        lxc exec $vm -- sh -c "echo 'fs.inotify.max_user_instances = 1048576' | tee --append /etc/sysctl.conf"        &> /dev/null
        lxc exec $vm -- sh -c "echo 'fs.inotify.max_user_watches = 1048576' | tee --append /etc/sysctl.conf"          &> /dev/null
        lxc exec $vm -- sh -c "echo 'vm.max_map_count = 262144' | tee --append /etc/sysctl.conf"                      &> /dev/null
        lxc exec $vm -- sh -c "echo 'kernel.dmesg_restrict = 0' | tee --append /etc/sysctl.conf"                      &> /dev/null
        lxc exec $vm -- sh -c "echo '* soft nofile 1048576' | tee --append /etc/security/limits.conf"                 &> /dev/null
        lxc exec $vm -- sh -c "echo '* hard nofile 1048576' | tee --append /etc/security/limits.conf"                 &> /dev/null
        lxc exec $vm -- sh -c "echo 'root soft nofile 1048576' | tee --append /etc/security/limits.conf"              &> /dev/null
        lxc exec $vm -- sh -c "echo 'root hard nofile 1048576' | tee --append /etc/security/limits.conf"              &> /dev/null
        lxc exec $vm -- sh -c "echo '* soft memlock unlimited' | tee --append /etc/security/limits.conf"              &> /dev/null
        lxc exec $vm -- sh -c "echo '* hard memlock unlimited' | tee --append /etc/security/limits.conf"              &> /dev/null
        lxc exec $vm -- sh -c "sysctl -p"                                                                             &> /dev/null
    done
}
echo ">>>>>>>>>>>>>>>[Doing some performance tuneup for VMs ... ]"
read_properties
initialize
optimize_vms
echo ""
