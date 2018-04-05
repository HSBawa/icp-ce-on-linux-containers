#!/bin/bash
pod_check_interval=20
if [ "$#" -eq 0 ]; then
    dev_master="dev-master"
else
    dev_master=$1
fi
running=$(lxc exec $dev_master -- kubectl -s 127.0.0.1:8888 get pods --field-selector=status.phase=Running --no-headers=true --all-namespaces | wc -l)
completed=$(lxc exec $dev_master -- kubectl -s 127.0.0.1:8888 get pods --no-headers=true --all-namespaces | grep Completed | wc -l)
ready=$(($running+$completed))
total=$(lxc exec $dev_master -- kubectl -s 127.0.0.1:8888 get pods --no-headers=true --all-namespaces | wc -l)
if [ "$ready" != "$total" ]; then
    echo "Not all pods are running or completed. Checking pod status every $pod_check_interval seconds."
fi
while [ "$ready" != "$total" ]; do
  echo -ne "$ready/$total process are running or completed"\\r
  sleep $pod_check_interval
  running=$(lxc exec $dev_master -- kubectl -s 127.0.0.1:8888 get pods --field-selector=status.phase=Running --no-headers=true --all-namespaces | wc -l)
  completed=$(lxc exec $dev_master -- kubectl -s 127.0.0.1:8888 get pods --no-headers=true --all-namespaces | grep Completed | wc -l)
  ready=$(($running+$completed))
done
echo "All $ready/$total processes are running. ICP is now ready for use."
