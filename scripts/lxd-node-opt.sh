#!/bin/bash
################################################################################
## This script will optimize VM nodes
################################################################################
env=$1
vms=$2

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
if [[ -z "$2" ]]; then
   vms=($(lxc list ${env}- -c n --format=csv))
fi
optimize_vms
echo ""
