#!/bin/bash

#####################################################################
## Start and stop K8S cluster
## hsbawa@us.ibm.com hsbawa@gmail.com
#####################################################################

input=$1

function  read_properties() {
  while IFS== read -r KEY VALUE
  do
      if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
        export "$KEY=$VALUE"
      fi
  done < ./install.properties
}



function invalid_command(){
    echo "This script will start, stop or restart Docker and Kubelet on cluster nodes."
    echo "Usage: start_stop_cluster.sh <start|stop|restart>"
    exit
}

function start_stop_cluster(){
    local vms=($(lxc list ${ICP_ENV_NAME_SHORT}- -c n --format=csv))
    if [[ $input =~ ^(start|stop|restart)$ ]]; then
       for vm  in ${vms[*]}
       do
          echo "Changing server $vm Docker state to: $input"
          lxc exec $vm  -- sh -c "systemctl $input docker"
          echo "Changing server $vm Kubelet state to: $input"
          lxc exec $vm  -- sh -c "systemctl $input kubelet"
       done
    else
       invalid_command
    fi
}

if [[ -z "$input" ]]; then
    invalid_command
fi


start_stop_cluster
