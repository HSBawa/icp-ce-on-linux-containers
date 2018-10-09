#!/bin/bash
if [[ ! -z $1 ]]; then
    env=$1
    echo "This program is going to destory all IBM Cloud Private [$env] cluster in next 10 secs. Press Ctrl-C to cancel now."
#    sleep 10
    vms="$(lxc list ${env}- -c n --format=csv)"
    echo Deleting VMs: $vms
    lxc stop -f $vms ; lxc delete -f $vms
    echo ""
    echo Deleting Profiles: $vms ${env}-common
    lxc profile delete ${env}-common
    profiles=($vms)
    for profile in ${profiles[*]}
    do
      lxc profile delete $profile
    done
    echo ""
    ## NOTE: Following call will fail if the name is set different than 'br0' in terraform config while creating network
    ## If not deleted, delete it manually: lxc network delete <name>
    echo "Deleting network: ${env}br0"
    lxc network delete ${env}br0
    echo ""
    echo "Done"
else
    echo "Missing environment name parameter. Enviroment name is env-prefix from terraform variables"
fi
