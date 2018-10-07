#!/bin/bash

################################################################################
## Create hosts file for install
## Update /etc/hosts file for VMs
################################################################################
env=$1
minimal=$2
vms=$3
#vms=()
array_size=${#vms[*]}
if [[ "$array_size" -eq 0  ]]; then
    echo "Getting VM info"
    vms=($(lxc list ${env}- -c n --format=csv))
fi
## VM IPs
vm_ips=()
master="[master]"
proxy="[proxy]"
mgmt="[management]"
va="[va]"
worker="[worker]"

################################################################################
## Create hosts file for install
################################################################################

function create_etc_hosts_file(){
    echo ""                                                                        | tee -a ./cluster/hosts  &> /dev/null
    echo "#### Auto-generated file"                                                | tee -a ./cluster/hosts  &> /dev/null
    echo "127.0.0.1 localhost"                                                     | tee ./cluster/etc-hosts &> /dev/null
    for index in ${!vms[*]}
    do
        vm=${vms[$index]}
        vm_ips[$index]=$(lxc exec  ${vms[$index]} -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
        ## Update VM /etc/hosts file
        echo ${vm_ips[$index]} $vm                                                 | tee -a ./cluster/etc-hosts &> /dev/null
        case "$vm" in
             *master*)
                 master="$master ${vm_ips[$index]}"
                 ## If minimal, then use master IP for proxy and management
                 if [[ "$minimal" == "1" ]]; then
                     proxy="$proxy ${vm_ips[$index]}"
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
    echo "#######################################################################" | tee    ./cluster/hosts &> /dev/null
    echo "##                  !!!!WARNING!!!!                                    " | tee -a ./cluster/hosts &> /dev/null
    echo "##             This file is auto-generated.                            " | tee -a ./cluster/hosts &> /dev/null
    echo "##  Any updates will be overwritten in next setup/install process      " | tee -a ./cluster/hosts &> /dev/null
    echo "#######################################################################" | tee -a ./cluster/hosts &> /dev/null
    echo ""                                                                        | tee -a ./cluster/hosts &> /dev/null
    echo "$master" | tr ' ' '\n'                                                   | tee -a ./cluster/hosts &> /dev/null
    echo ""                                                                        | tee -a ./cluster/hosts &> /dev/null
    echo "$proxy" | tr ' ' '\n'                                                    | tee -a ./cluster/hosts &> /dev/null
    echo ""                                                                        | tee -a ./cluster/hosts &> /dev/null
    echo "$mgmt" | tr ' ' '\n'                                                     | tee -a ./cluster/hosts &> /dev/null
    echo ""                                                                        | tee -a ./cluster/hosts &> /dev/null
    echo "$worker" | tr ' ' '\n'                                                   | tee -a ./cluster/hosts &> /dev/null

    echo "./cluster/etc-hosts"
    cat ./cluster/etc-hosts
    echo ""
    echo "./cluster/hosts"
    cat ./cluster/hosts
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
        lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./cluster/etc-hosts $vm/etc/hosts
    done
}

echo ">>>>>>>>>>>>>>>[Creating hosts file for VMs... ]"
create_etc_hosts_file
echo ""
echo ">>>>>>>>>>>>>>>[Copying hosts file to all VMs... ]"
copy_etc_hosts_file
echo ""
