#!/bin/bash
if [[ ! -z $1 ]]; then
    env=$1
    echo "This program is going to destory all IBM Cloud Private [$env] cluster in next 10 secs. Press Ctrl-C to cancel now."
    sleep 10
    lxc stop -f $(lxc list ${env}- -c n --format=csv)
    lxc delete -f $(lxc list ${env}- -c n --format=csv)
    lxc profile delete ${env}-common
    lxc profile delete ${env}-boot
    lxc profile delete ${env}-master
    lxc profile delete ${env}-mgmt
    lxc profile delete ${env}-va
    lxc profile delete ${env}-proxy
    lxc profile delete ${env}-worker-1
    lxc profile delete ${env}-worker-2
    lxc profile delete ${env}-worker-3
    lxc network delete ${env}br0
    lxc network delete ${env}br1
else
    echo "Missing environment name parameter. Enviroment name is env-prefix from terraform variables"
fi
