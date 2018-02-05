#!/bin/bash
###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
echo ">>>>>>>>>>>>>>>Linux Container (LXC) cluster for '$8' enviromnet is now ready."
echo -n ">>>>>>>>>>>>>>>Waiting for nodes to settle down ... "
sleep 20
echo "done."
echo ">>>>>>>>>>>>>>>[Initializing LXC node $1 ... ]"
ts=$(date +'%Y%m%d-%H%M%S')

echo ">>>>>>>>>>>>>>>[Updating config.yaml ... ]"
cp ./cluster/config.yaml.tmpl ./cluster/config.yaml

if [[ ! -z $9 ]]; then
    echo "default_admin_password: $9" >> ./cluster/config.yaml
fi
if [[ ! -z ${10} ]]; then
    echo "disabled_management_services: ${10}" >> ./cluster/config.yaml
fi

if [[ ! -z ${11} ]]; then
    echo "cluster_name: ${11} " >> ./cluster/config.yaml
fi

if [[ ! -z ${12} ]]; then
    echo "cluster_domain: ${12}" >> ./cluster/config.yaml
fi

if [[ ! -z ${13} ]]; then
    echo "cluster_CA_domain: \"${13}\" " >> ./cluster/config.yaml
fi

echo ">>>>>>>>>>>>>>>[Backing up RSA keys on local host ... ]"
mv ./ssh-keys/id_rsa ./ssh-keys/id_rsa.bak &> /dev/null
mv ./ssh-keys/id_rsa.pub ./ssh-keys/id_rsa.pub.bak &> /dev/null
# mv ./ssh-keys/id_rsa ./ssh-keys/id_rsa.$ts &> /dev/null
# mv ./ssh-keys/id_rsa.pub ./ssh-keys/id_rsa.pub.$ts &> /dev/null

echo ">>>>>>>>>>>>>>>[Backing up hosts file on local host ... ]"
mv ./cluster/hosts ./cluster/hosts.bak &> /dev/null
#mv ./cluster/hosts ./cluster/hosts.$ts &> /dev/null

echo ">>>>>>>>>>>>>>>[Generating new RSA keys on local host ... ]"
/usr/bin/ssh-keygen -t rsa -b 4096 -f ./ssh-keys/id_rsa -N '' -C 'icp-on-lxc'

echo ">>>>>>>>>>>>>>>[Generating hosts file on local host ... ]"
###############################################################################
## Get node IPs
## Replace node ip lookup with your desired script, if following does not work.
###############################################################################
boot_ip=$(lxc exec  $1 -- ip route get 1 | awk '{print $NF;exit}')
master_ip=$(lxc exec $2 -- ip route get 1 | awk '{print $NF;exit}')
mgmt_ip=$(lxc exec $3 -- ip route get 1 | awk '{print $NF;exit}')
proxy_ip=$(lxc exec $4 -- ip route get 1 | awk '{print $NF;exit}')
worker_1_ip=$(lxc exec $5 -- ip route get 1 | awk '{print $NF;exit}')
worker_2_ip=$(lxc exec $6 -- ip route get 1 | awk '{print $NF;exit}')
worker_3_ip=$(lxc exec $7 -- ip route get 1 | awk '{print $NF;exit}')

# boot_ip="$(lxc exec  $1 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
# master_ip="$(lxc exec $2 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
# mgmt_ip="$(lxc exec $3 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
# proxy_ip="$(lxc exec $4 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
# worker_1_ip="$(lxc exec $5 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
# worker_2_ip="$(lxc exec $6 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
# worker_3_ip="$(lxc exec $7 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"

echo "$boot_ip $1"
echo "$master_ip $2"
echo "$mgmt_ip $3"s
echo "$proxy_ip $4"
echo "$worker_1_ip $5"
echo "$worker_2_ip $6"
echo "$worker_3_ip $7"

###############################################################################
## Doing some performance tuneup for master node
## Same applies to Linux Host
###############################################################################
echo ">>>>>>>>>>>>>>>[Doing some performance tuneup for $2 ... ]"
lxc exec $2 -- sh -c "echo 'fs.inotify.max_queued_events = 1048576' | tee --append /etc/sysctl.conf" &> /dev/null
lxc exec $2 -- sh -c "echo 'fs.inotify.max_user_instances = 1048576' | tee --append /etc/sysctl.conf" &> /dev/null
lxc exec $2 -- sh -c "echo 'fs.inotify.max_user_watches = 1048576' | tee --append /etc/sysctl.conf" &> /dev/null
lxc exec $2 -- sh -c "echo 'vm.max_map_count = 262144' | tee --append /etc/sysctl.conf" &> /dev/null
lxc exec $2 -- sh -c "echo 'kernel.dmesg_restrict = 0' | tee --append /etc/sysctl.conf" &> /dev/null
lxc exec $2 -- sh -c "echo '* soft nofile 1048576' | tee --append /etc/security/limits.conf" &> /dev/null
lxc exec $2 -- sh -c "echo '* hard nofile 1048576' | tee --append /etc/security/limits.conf" &> /dev/null
lxc exec $2 -- sh -c "echo 'root soft nofile 1048576' | tee --append /etc/security/limits.conf" &> /dev/null
lxc exec $2 -- sh -c "echo 'root hard nofile 1048576' | tee --append /etc/security/limits.conf" &> /dev/null
lxc exec $2 -- sh -c "echo '* soft memlock unlimited' | tee --append /etc/security/limits.conf" &> /dev/null
lxc exec $2 -- sh -c "echo '* hard memlock unlimited' | tee --append /etc/security/limits.conf" &> /dev/null
lxc exec $2 -- sh -c "sysctl -p" &> /dev/null

###############################################################################
## Template to Load Docker Images from archive (if available)
###############################################################################
# docker_img_folder=/share/icp2101ce/
# icp_common_img="$docker_img_folder/icp-2101-ce-common.tar.gz"
# icp_boot_img="$docker_img_folder/icp-2101-ce-boot.tar.gz"
# icp_master_img="$docker_img_folder/icp-2101-ce-master.tar.gz"
# icp_mgmt_img="$docker_img_folder/icp-2101-ce-mgmt.tar.gz"
# icp_proxy_img="$docker_img_folder/icp-2101-ce-proxy.tar.gz"
# icp_worker_img="$docker_img_folder/icp-2101-ce-common.tar.gz"
# echo ">>>>>>>>>>>>>>>[Pre-loading docker images ... ]"
# echo ">>>>>>>>>>>>>>>Loading docker images on $1 ..."
# lxc exec $1 -- sh -c "docker load -i $icp_boot_img" &> /dev/null
# echo ">>>>>>>>>>>>>>>Loading docker images on $2 ..."
# lxc exec $2 -- sh -c "docker load -i $icp_master_img" &> /dev/null
# lxc exec $2 -- sh -c "docker load -i $icp_common_img" &> /dev/null
# echo ">>>>>>>>>>>>>>>Loading docker images on $3 ..."
# lxc exec $3 -- sh -c "docker load -i $icp_mgmt_img" &> /dev/null
# lxc exec $3 -- sh -c "docker load -i $icp_common_img" &> /dev/null
# echo ">>>>>>>>>>>>>>>Loading docker images on $4 ..."
# lxc exec $4 -- sh -c "docker load -i $icp_proxy_img" &> /dev/null
# lxc exec $4 -- sh -c "docker load -i $icp_common_img" &> /dev/null
# echo ">>>>>>>>>>>>>>>Loading docker images on $5 ..."
# lxc exec $5 -- sh -c "docker load -i $icp_worker_img" &> /dev/null
# echo ">>>>>>>>>>>>>>>Loading docker images on $6 ..."
# lxc exec $6 -- sh -c "docker load -i $icp_worker_img" &> /dev/null
# echo ">>>>>>>>>>>>>>>Loading docker images on $7 ..."
# lxc exec $7 -- sh -c "docker load -i $icp_worker_img" &> /dev/null
###############################################################################
## Generate hosts file
###############################################################################
echo ">>>>>>>>>>>>>>>[Generating hosts file for ICP CE ... ]"
echo "### WARNING: This file is autogenerated during installation." > ./cluster/hosts
echo "### All manual changes will be overwritten in next install." >> ./cluster/hosts
echo "[master]" >> ./cluster/hosts
echo $master_ip >> ./cluster/hosts
echo "" >> ./cluster/hosts
echo "[proxy]" >>./cluster/hosts
echo $proxy_ip >> ./cluster/hosts
echo "" >> ./cluster/hosts
echo "[management]" >>./cluster/hosts
echo $mgmt_ip >> ./cluster/hosts
echo "" >> ./cluster/hosts
echo "[worker]" >>./cluster/hosts
echo $worker_1_ip >> ./cluster/hosts
echo $worker_2_ip >> ./cluster/hosts
echo $worker_3_ip >> ./cluster/hosts
echo "" >> ./cluster/hosts
cat ./cluster/hosts

echo ">>>>>>>>>>>>>>>[Updating node hosts file ... ]"
lxc exec $1 -- sh -c  "echo $boot_ip $1 >> /etc/hosts"
lxc exec $2 -- sh -c  "echo $master_ip $2 >> /etc/hosts"
lxc exec $3 -- sh -c  "echo $mgmt_ip  $3 >> /etc/hosts"
lxc exec $4 -- sh -c  "echo $proxy_ip $4 >> /etc/hosts"
lxc exec $5 -- sh -c  "echo $worker_1_ip $5 >> /etc/hosts"
lxc exec $6 -- sh -c  "echo $worker_2_ip $6 >> /etc/hosts"
lxc exec $7 -- sh -c  "echo $worker_3_ip $7 >> /etc/hosts"

echo ">>>>>>>>>>>>>>>[Docker pull ibmcom/icp-inception:2.1.0.1 ... ]"
lxc exec $1 -- sh -c "docker pull ibmcom/icp-inception:2.1.0.1"
lxc exec $1 -- sh -c "docker run -e LICENSE=accept -v /opt/icp-2101-ce:/data ibmcom/icp-inception:2.1.0.1 cp -r cluster /data"
sleep 10
lxc exec $1 -- sh -c "ls -al /opt/icp-2101-ce/cluster"

echo ">>>>>>>>>>>>>>>[Copying ICP config data to $1 ... ]"
###############################################################################
## Copy ICP config data to boot node
###############################################################################
# lxc exec $1 -- mkdir -p /opt/icp-2101-ce/cluster
lxc exec $1 -- mkdir -p /root/cluster/
lxc exec $1 -- mkdir -p /opt/icp-2101-ce/bin
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ./cluster/config.yaml $1/root/cluster/config.yaml
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ./cluster/hosts $1/root/cluster/hosts
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa $1/root/.ssh/id_rsa
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $1/root/.ssh/id_rsa.pub
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/install.sh $1/opt/icp-2101-ce/bin/install.sh
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/install-dbg.sh $1/opt/icp-2101-ce/bin/install-dbg.sh
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/uninstall.sh $1/opt/icp-2101-ce/bin/uninstall.sh
lxc exec $1 -- sh -c  "cp /root/.ssh/id_rsa /opt/icp-2101-ce/cluster/ssh_key"
lxc exec $1 -- sh -c "cp /root/cluster/hosts /opt/icp-2101-ce/cluster/hosts"
lxc exec $1 -- sh -c "cp /root/cluster/config.yaml /opt/icp-2101-ce/cluster/config.yaml"
lxc exec $1 -- sh -c "ls -al /opt/icp-2101-ce/cluster"

###############################################################################
## Copy authorized keys to non-boot nodes
###############################################################################
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $2/root/.ssh/authorized_keys
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $3/root/.ssh/authorized_keys
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $4/root/.ssh/authorized_keys
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $5/root/.ssh/authorized_keys
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $6/root/.ssh/authorized_keys
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $7/root/.ssh/authorized_keys
###############################################################################
## Install kubectl on master node
###############################################################################
echo ">>>>>>>>>>>>>>>[Instaling kubectl on $2]"
lxc exec $2 -- sh -c  "curl -o /usr/local/bin/kubectl -fssLO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl; chmod +x /usr/local/bin/kubectl &> /dev/null &> /dev/null"
echo ">>>>>>>>>>>>>>>[Done initializing LXC node $1]"
###############################################################################
## Start ICP Installation
###############################################################################
echo ">>>>>>>>>>>>>>>[Starting ICP installation now]"
echo ">>>>>>ICP install will complete in 30 mins to 1+ hours depending on your system resource configuration and internet speed.<<<<<"
echo ">>>>>>You can watch your nodes getting updated, from a different VM shell, using command 'watch lxc list $8-'.<<<<<"
lxc exec $1 -- sh -c "/opt/icp-2101-ce/bin/install.sh"
success=$?
if [ $success -eq 0 ]; then
    pod_check_interval=20
    echo ""
    echo ">>>>>>>>>>>>>>>[ICP installation was success]"
    echo ">>>>>>>>>>>>>>>Checking if all pods are up and running ... "
    running=$(lxc exec $2 -- kubectl -s 127.0.0.1:8888 get pods --field-selector=status.phase=Running --no-headers=true --all-namespaces | wc -l)
    total=$(lxc exec $2 -- kubectl -s 127.0.0.1:8888 get pods --no-headers=true --all-namespaces | wc -l)
    if [ "$running" != "$total" ]; then
        echo ">>>>>>>>>>>>>>>Looks like only $running/$total pods are running."
        echo ">>>>>>>>>>>>>>>Waiting for ICP to settle down. Checking pod status every $pod_check_interval seconds."
        sleep $pod_check_interval
    fi
    while [ "$running" != "$total" ]; do
      # echo -ne ">>>>>>>>>>>>>>>$running/$total pods are running ..."\\r
      echo ">>>>>>>>>>>>>>> $running/$total pods are running ..."
      sleep $pod_check_interval
      running=$(lxc exec $2 -- kubectl -s 127.0.0.1:8888 get pods --field-selector=status.phase=Running --no-headers=true --all-namespaces | wc -l)
    done
    echo ">>>>>>>>>>>>>>>All $running/$total pods are up and running."
    echo ">>>>>>>>>>>>>>>[If you have not installed kubectl and IBM Cloud CLI (bx), now is good time to install on your host machine.]"
    echo "Next, once you download ICP CLI following are some helpful commands for your environment setup and use."
    echo "Following commands will be saved in 'icp-login.sh' file for login easeness and cluster config."
    echo "##Contents of this file will be replaced on next successful install" | tee icp-login.sh
    echo "## Default values will be replaced with values from terraform variables (if changed)" | tee -a icp-login.sh
    echo "# Run following command once and only if ICP plugin is not installed for IBM Cloud CLI"  | tee -a icp-login.sh
    echo "bx plugin install icp-linux-amd64" | tee -a icp-login.sh
    echo "# Validate ICP CLI plugin install" | tee -a icp-login.sh
    echo "bx plugin show icp" | tee -a icp-login.sh
    echo "# Login to ICP CE" | tee -a icp-login.sh
    echo "bx pr login -a https://$master_ip:8443 -u admin -p $9 -c id-icp-account --skip-ssl-validation" | tee -a icp-login.sh
    echo "# Cluster config " | tee -a icp-login.sh
    echo "bx pr cluster-config ${11}" | tee -a icp-login.sh
    # echo "bx pr cluster-config mycluster" | tee -a icp-login.sh
    echo "# Validate kubectl is working" | tee -a icp-login.sh
    echo "kubectl get nodes" | tee -a icp-login.sh
    echo "# Information about clusters" | tee -a icp-login.sh
    echo "bx pr clusters" | tee -a icp-login.sh
    echo "# Get cluster specific info" | tee -a icp-login.sh
    echo "bx pr cluster-get ${11}" | tee -a icp-login.sh
    # echo "bx pr cluster-get mycluster" | tee -a icp-login.sh
    echo ">>>>>>>>>>>>>>>[INSTALL COMPLETE - ICP ON LINUX CONTAINER IS READY TO USE]"
else
    echo ""
    echo "INSTALL FAILED - $success"
    echo "echo 'INSTALL FAILED - $success'" | tee icp-login.sh &> /dev/null
fi
