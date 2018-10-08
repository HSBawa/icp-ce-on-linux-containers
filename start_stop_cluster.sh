#!/bin/bash
 
input=$1
env=$2

function invalid_command(){
    echo "This script will to start, stop or restart Docker on cluster nodes."
    echo "Usage: start_stop_cluster.sh <start|stop|restart> <env>"
    exit
}

function start_stop_docker(){
    local vms=($(lxc list ${env}- -c n --format=csv))
    if [[ $input =~ ^(start|stop|restart)$ ]]; then
       for vm  in ${vms[*]}
       do
          echo "Changing server $vm Docker state to: $input"
          lxc exec $vm  -- sh -c "systemctl restart docker"
       done
    else
       invalid_command
    fi
}

if [[ -z "$input" ]]; then
    invalid_command
fi

if [[ -z "$env" ]]; then
    invalid_command
fi

start_stop_docker
