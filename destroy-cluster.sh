#!/bin/bash

function  read_properties() {
  while IFS== read -r KEY VALUE
  do
      if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
        export "$KEY=$VALUE"
      fi
  done < ./install.properties
}

function clear_haproxy_cfg(){
  ## Clear existing configuration
  if grep -Fxq "${HAPROXY_ICP_MARKER_START}" ${HAPROXY_CFG} && grep -Fxq "${HAPROXY_ICP_MARKER_END}" ${HAPROXY_CFG}
    then
      echo "Configuration exists. Overwriting ..."
      lineNumStart="$(grep -n "${HAPROXY_ICP_MARKER_START}" ${HAPROXY_CFG} | head -n 1 | cut -d: -f1)"
      lineNumEnd="$(grep -n "${HAPROXY_ICP_MARKER_END}" ${HAPROXY_CFG} | head -n 1 | cut -d: -f1)"
      sudo sed -i "${lineNumStart},${lineNumEnd}d" ${HAPROXY_CFG}
      sudo systemctl restart haproxy.service
      if [[ $? -ne 0 ]]; then
        echo "ERROR!!! HAProxy service restart failed."
      fi
  fi
}

function destory_cluster(){
  if [[ ! -z ${ICP_ENV_NAME_SHORT} ]]; then
      env=${ICP_ENV_NAME_SHORT}
      vms="$(lxc list ${env}- -c n --format=csv)"
      profiles="$(lxc profile list | grep ${env} | awk '{print $2}')"
      networks="$(lxc network list | grep ${env} | awk '{print $2}')"
      lineNumStart="$(grep -n "${HAPROXY_ICP_MARKER_START}" ${HAPROXY_CFG} | head -n 1 | cut -d: -f1)"
      if [[ $? -ne 0  ]] || [[ -z ${lineNumStart}  ]]; then
          lineNumStart=0
      fi
      lineNumEnd="$(grep -n "${HAPROXY_ICP_MARKER_END}" ${HAPROXY_CFG} | head -n 1 | cut -d: -f1)"
      if [[ $? -ne 0  ]] || [[ -z ${lineNumEnd}  ]]; then
          lineNumEnd=0
      fi

      if [[ ! -z ${vms} ]] || [[ ! -z ${profiles} ]]  || [[ ! -z ${networks} ]] || [[ ${lineNumStart} -gt 0 ]] || [[ ${lineNumEnd} -gt 0 ]]; then
        echo "This program will delete following IBM Cloud Private [$env] cluster LXD components."
        if [[ ! -z "${vms}" ]]; then
          echo "Containers: $vms"
        fi
        if [[ ! -z  ${profiles} ]]; then
          echo "Profile: $profiles"
        fi

        if [[ ! -z ${networks} ]]; then
          echo "Networks: $networks"
        fi

        if [[ ${lineNumStart} -gt 0 ]] || [[ ${lineNumEnd} -gt 0 ]]; then
          echo "ICP HAPRoxy configuration."
        fi

        echo "Press Ctrl-C to cancel now OR in next 10 seconds they are gone ...."
        sleep 10

        for vm in ${vms[*]}
        do
          # echo "Deleting container: ${vm}"
          lxc stop -f $vm ; lxc delete -f $vm
        done
        echo ""

        for profile in ${profiles[*]}
        do
          # echo "Deleting profile: ${profile}"
          lxc profile delete $profile
        done
        echo ""

        for network in ${networks[*]}
        do
          # echo "Deleting network: ${network}"
          lxc network delete $network
        done
        echo ""

        echo "Cleaning ICP HAProxy configuration:"
        clear_haproxy_cfg
        echo ""

        echo "Done"
      else
        echo "There are no LXD components to delete at this time. Bye."
      fi
  else
      echo "Invalid environment name: ${ICP_ENV_NAME_SHORT}. Please try again with valid environment name."
  fi
}

read_properties
destory_cluster
