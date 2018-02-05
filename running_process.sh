#!/bin/bash
pod_check_interval=20
running=$(lxc exec dev-master -- kubectl -s 127.0.0.1:8888 get pods --field-selector=status.phase=Running --no-headers=true --all-namespaces | wc -l)
#running=45
total=$(lxc exec dev-master -- kubectl -s 127.0.0.1:8888 get pods --no-headers=true --all-namespaces | wc -l)
if [ "$running" != "$total" ]; then
    echo "Not all pods are running. Checking pod status every $pod_check_interval seconds."
fi
while [ "$running" != "$total" ]; do
  echo -ne "$running/$total process are running"\\r
  sleep $pod_check_interval
  running=$(lxc exec dev-master -- kubectl -s 127.0.0.1:8888 get pods --field-selector=status.phase=Running --no-headers=true --all-namespaces | wc -l)
  # running=$(($running+1))
done
echo "All $running/$total processes are running. ICP is now ready for use."
