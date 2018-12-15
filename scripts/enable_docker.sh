#!/bin/bash
################################################################################
## This script will fix docker issue while enabling Docker/Containerd service
################################################################################
env=$1
vms=$2

if [[ -z "$2" ]]; then
   vms=($(lxc list ${env}- -c n --format=csv))
fi

function enable_docker(){
    for vm in ${vms[*]}
    do
        echo "$vm"
        lxc exec $vm -- sh -c "rm /etc/systemd/system/multi-user.target.wants/docker.service"
        lxc exec $vm -- sh -c "systemctl daemon-reload"
        lxc exec $vm -- sh -c "systemctl restart docker"
        lxc exec $vm -- sh -c "systemctl enable docker"
    done
}
enable_docker
echo ""
