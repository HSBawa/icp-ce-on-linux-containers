#!/bin/bash

INSTALL_PROPERTIES="./install.properties"

function  read_properties() {
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

################################################################################
# Check if the available disk space as per recommendation
################################################################################
function check_for_vm_root_size(){
  if [[ -z "${ICP_ENV_NAME_SHORT}" ]]; then
    env="dev"
  fi

  if [[ -z "${ICP_MIN_AVAIL_ROOT_SIZE}" ]]; then
    ICP_MIN_AVAIL_ROOT_SIZE=20
  fi
  vms=($(lxc list ${env}- -c n --format=csv))

  for vm in ${vms[*]}
  do
     vm_root_size=$(lxc exec $vm -- sh -c "df -lh -BG --output=avail / | sed '1d' | grep -oP '\d+'")
     if [[  $vm_root_size -lt ${ICP_MIN_AVAIL_ROOT_SIZE}  ]];
     then
        echo "VM root size ${vm_root_size}GB is less than recommended ${ICP_MIN_AVAIL_ROOT_SIZE}GB"
        echo "You can validate size for this node, using command 'lxc profile show ${vm}'. See below an example output section:"
        echo ""
        echo "  root:"
        echo "    path: /"
        echo "    pool: default"
        echo "    size: 30GB"
        echo "    type: disk"
        echo ""
        echo "Update in 'install.properties' value for ICP_XXXX_STORAGE_DEVICE_SIZE for this VM."
        echo "Next, destroy cluster and re-build it again"
        echo "Exiting now."
        exit
     else
        echo "$vm - Ok"
     fi
 done
}

echo ">>>>>>>>>>>>>>>[Checking VM root disk size ... ]"
read_properties
check_for_vm_root_size
echo ""
