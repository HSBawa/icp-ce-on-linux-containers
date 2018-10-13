#!/bin/bash

env=$1
minimal=$2
## ICP Basic
version=$3
edition=$4
icp_installer=$5
install_dbg=$6
recommended_root_size=$7
### Cluster Basic
admin_user=$8
admin_pass=$9
cluster_name=${10}
cluster_domain=${11}
cluster_CA_domain="${12}"
default_namespace=${13}
boot_node_grep_key=${14}
cluster_lb_address=$(echo ${15} | tr ',' ' ' | xargs)
proxy_lb_address=$(echo ${16} | tr ',' ' ' | xargs)
disabled_management_services=${17}

### Environment
if [[ -z "$env" ]]; then
   echo "Environment parameter is required. Exiting ICP Setup process"
   exit
fi
# ## ICP Basic
# minimal="false"
# version="3.1.0"
# edition="ce"
# icp_installer="ibmcom/icp-inception"
# install_dbg="false"
# recommended_root_size=20
# ### Cluster Basic
# admin_user="admin"
# admin_pass="admin_0000"
# cluster_name="devicpcluster"
# cluster_domain="cluster.local"
# cluster_CA_domain="{{ cluster_name }}.icp"



vms=()
vm_ips=()

################################################################################
## Get IP for LXD Machines
################################################################################
function get_ips(){
    for index in ${!vms[*]}
    do
        item=${vms[$index]}
        vm_ips[$index]=$(lxc exec  ${vms[$index]} -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
    done
}

function pause(){
   read -p "$*"
}



echo ">>>>>>>>>>>>>>>[Retrieving LXD VMs for environment $env ... ]"
vms=($(lxc list ${env}- -c n --format=csv))
echo ""
## Extract IPs
echo ">>>>>>>>>>>>>>>[Retrieving LXD VMs IPs ... ]"
get_ips
echo ""

## VM Performance tuning
source ./scripts/lxd-node-opt.sh $env ${vms[*]}

## Back up the existing configuration
source ./scripts/backup.sh

## Create SSH Keys
source ./scripts/ssh-keys.sh $env $version $edition ${vms[*]}

## Update Config File


source ./scripts/config-update.sh $admin_user $admin_pass $cluster_name $cluster_domain "$cluster_CA_domain" $cluster_lb_address $proxy_lb_address "$disabled_management_services"

## Create Hosts file and update VMs /etc/hosts file
## TODO: Fix issue passing multiple arrays (vm names and their ips)
source ./scripts/create-hosts-file.sh $env $minimal ${vms[*]}

## Create for VM root size
source ./scripts/check-root-size.sh $env $recommended_root_size ${vms[*]}

## Prepare boot node and start install
echo "Executing: source ./scripts/prepare-boot-node.sh $env $version $edition $icp_installer $install_dbg $boot_node_grep_key"
source ./scripts/prepare-boot-node.sh $env $version $edition $icp_installer $install_dbg $boot_node_grep_key $cluster_name $default_namespace $admin_user $admin_pass
