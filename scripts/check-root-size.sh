#!/bin/bash

env=$1
recommended_root_size=$2
vms=$3

if [[ -z "$env" ]]; then
  env="test"
fi

if [[ -z "$recommended_root_size" ]]; then
  recommended_root_size=20
fi

if [[ -z $3 ]]; then
    echo "Getting VMs"
    vms=($(lxc list ${env}- -c n --format=csv))
fi

################################################################################
# Check if the available disk space as per recommendation
################################################################################
function check_for_vm_root_size(){
    for vm in ${vms[*]}
    do
       vm_root_size=$(lxc exec $vm -- sh -c "df -lh -BG --output=avail / | sed '1d' | grep -oP '\d+'")
       if [[  $vm_root_size -lt $recommended_root_size  ]];
       then
          echo "VM root size ${vm_root_size}GB is less than recommended ${recommended_root_size}GB"
          echo "You can validate size for this node, using command 'lxc profile show ${vm}'. See below an example output section:"
          echo ""
          echo "  root:"
          echo "    path: /"
          echo "    pool: default"
          echo "    size: 30GB"
          echo "    type: disk"
          echo ""
          echo "Run command ex:  'lxc profile edit test-master-0 , update/add size property and then save it."
          echo "This value can also be set in 'variables.tf -> xxxx_node -> storage_device_size'. This will require cluster rebuild"
          echo "Next, destroy cluster and re-build it again"
          echo "Exiting now."
          exit
       else
          echo "$vm - Ok"
       fi
   done
}

echo ">>>>>>>>>>>>>>>[Checking VM root disk size ... ]"
check_for_vm_root_size
echo ""
