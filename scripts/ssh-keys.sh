#!/bin/bash
env=$1
version=$2
edition=$3
vms=$4
echo ">>>>>>>>>>>>>>>[Generating SSH RSA keys for $env-icp-$version-$edition-on-lxc... ]"
echo ""
/usr/bin/ssh-keygen -t rsa -b 4096 -f ./ssh-keys/id_rsa -N '' -C "$env-icp-$version-$edition-on-lxc"
cp ./ssh-keys/id_rsa ./cluster/ssh_key
## Copy authorized keys
#echo "VMs= ${vms[*]}"
echo ""
echo ">>>>>>>>>>>>>>>[Updating SSH authorized_key on VMs ... ]"
echo ""
for vm in ${vms[*]}
do
    ## Add public key as authorized_keys
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $vm/root/.ssh/authorized_keys
done
