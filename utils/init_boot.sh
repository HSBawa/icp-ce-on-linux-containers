#!/bin/bash
###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
env=$8
echo ">>>>>>>>>>>>>>>Linux Container (LXD) cluster for '$env' environment is now ready."
echo -n ">>>>>>>>>>>>>>>Waiting for cluster vm nodes to settle down ... "
sleep 20
echo "done."

ts=$(date +'%Y%m%d-%H%M%S')
private_registry=${16}
icp_installer=${17}
version=${14}
edition=${15}
version_edition=${14}-$edition
icp_install_dbg=${24}
cluster_name=${11}
cluster_domain=${12}
cluster_CA_domain=${13}
cluster_zone=${env}zone
cluster_region=${env}region
default_admin_password=$9
disabled_management_services=${10}
install_kibana=${31}
if [[ $private_registry == "true" ]]; then
    version=${22}
    version_edition=${22}
    icp_installer=${23}
fi
boot_icp_dir="/opt/icp-$version_edition"
boot_icp_cluster_dir="$boot_icp_dir/cluster"
boot_icp_bin_dir="$boot_icp_dir/bin"
boot_icp_log_dir="$boot_icp_dir/log"
echo "Boot ICP dir = $boot_icp_dir"
echo "Boot ICP cluster dir = $boot_icp_cluster_dir"
echo "Boot ICP bin dir = $boot_icp_cluster_dir"
echo "Boot ICP log dir = $boot_icp_log_dir"

echo ">>>>>>>>>>>>>>>[Initializing LXD node $1 ... ]"
echo ">>>>>>>>>>>>>>>[Updating config.yaml ... ]"
if [[ $private_registry == "true" ]]; then
    cp ./cluster/config.yaml.tmpl.private ./cluster/config.yaml
else
    cp ./cluster/config.yaml.tmpl ./cluster/config.yaml
fi

if [[ ! -z $default_admin_password ]]; then
    echo "default_admin_password: $default_admin_password" >> ./cluster/config.yaml
fi
if [[ ! -z $disabled_management_services ]]; then
    echo "disabled_management_services: $disabled_management_services" >> ./cluster/config.yaml
fi

if [[ ! -z $cluster_name ]]; then
    echo "cluster_name: $cluster_name " >> ./cluster/config.yaml
fi

if [[ ! -z $cluster_domain ]]; then
    echo "cluster_domain: $cluster_domain" >> ./cluster/config.yaml
fi

if [[ ! -z $cluster_CA_domain ]]; then
    echo "cluster_CA_domain: \"$cluster_CA_domain\" " >> ./cluster/config.yaml
fi

if [[ ! -z $install_kibana ]]; then
    echo "kibana_install: $install_kibana " >> ./cluster/config.yaml
fi

echo "cluster_zone: $cluster_zone" >> ./cluster/config.yaml
echo "cluster_region: $cluster_region" >> ./cluster/config.yaml

if [[ $private_registry == "true" ]]; then
    echo "version: ${22}" >> ./cluster/config.yaml
    echo "image_repo: ${21}" >> ./cluster/config.yaml
    echo "private_registry_enabled: true" >> ./cluster/config.yaml
    echo "private_registry_server: ${20}" >> ./cluster/config.yaml
    echo "docker_username: ${18}" >> ./cluster/config.yaml
    echo "docker_password: ${19}" >> ./cluster/config.yaml
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
## Following IP Lookup commands works for artful and xenial only
## For bionic use $(NF-2)ex: boot_ip=$(lxc exec  $1 -- ip route get 1 | awk '{print $(NF-2);exit}')
#boot_ip=$(lxc exec  $1 -- ip route get 1 | awk '{print $NF;exit}')
#master_ip=$(lxc exec $2 -- ip route get 1 | awk '{print $NF;exit}')
#mgmt_ip=$(lxc exec $3 -- ip route get 1 | awk '{print $NF;exit}')
#proxy_ip=$(lxc exec $4 -- ip route get 1 | awk '{print $NF;exit}')
#worker_1_ip=$(lxc exec $5 -- ip route get 1 | awk '{print $NF;exit}')
#worker_2_ip=$(lxc exec $6 -- ip route get 1 | awk '{print $NF;exit}')
#worker_3_ip=$(lxc exec $7 -- ip route get 1 | awk '{print $NF;exit}')

## Following IP lookup commands works for bionic, artful and xenial.
boot_ip="$(lxc exec  $1 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
master_ip="$(lxc exec $2 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
mgmt_ip="$(lxc exec $3 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
proxy_ip="$(lxc exec $4 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
worker_1_ip="$(lxc exec $5 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
worker_2_ip="$(lxc exec $6 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
worker_3_ip="$(lxc exec $7 -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"

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
icp_docker_tar=${25}
icp_boot_img=${26}
icp_master_img=${27}
icp_mgmt_img=${28}
icp_proxy_img=${29}
icp_worker_img=${30}
if [[ $icp_docker_tar == "true" ]]; then
    echo ">>>>>>>>>>>>>>>[Pre-loading docker images from TAR files ... ]"
    echo ">>>>>>>>>>>>>>>Loading docker images on $1 ..."
    lxc exec $1 -- sh -c "docker load -i $icp_boot_img" &> /dev/null
    echo ">>>>>>>>>>>>>>>Loading docker images on $2 ..."
    lxc exec $2 -- sh -c "docker load -i $icp_master_img" &> /dev/null
    echo ">>>>>>>>>>>>>>>Loading docker images on $3 ..."
    lxc exec $3 -- sh -c "docker load -i $icp_mgmt_img" &> /dev/null
    echo ">>>>>>>>>>>>>>>Loading docker images on $4 ..."
    lxc exec $4 -- sh -c "docker load -i $icp_proxy_img" &> /dev/null
    echo ">>>>>>>>>>>>>>>Loading docker images on $5 ..."
    lxc exec $5 -- sh -c "docker load -i $icp_worker_img" &> /dev/null
    echo ">>>>>>>>>>>>>>>Loading docker images on $6 ..."
    lxc exec $6 -- sh -c "docker load -i $icp_worker_img" &> /dev/null
    echo ">>>>>>>>>>>>>>>Loading docker images on $7 ..."
    lxc exec $7 -- sh -c "docker load -i $icp_worker_img" &> /dev/null
fi
###############################################################################
## Generate hosts file
###############################################################################
echo ">>>>>>>>>>>>>>>[Generating hosts file for ICP v$version_edition ... ]"
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
echo "[va]" >>./cluster/hosts
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

echo ">>>>>>>>>>>>>>>[Docker pull $icp_installer:${version} ... ]"
if [[ $private_registry == "true" ]]; then
    lxc exec $1 -- sh -c "docker login -u ${18} -p ${19} ${20}"
fi
lxc exec $1 -- sh -c "docker pull $icp_installer:${version}"
lxc exec $1 -- sh -c "docker run -e LICENSE=accept -v $boot_icp_dir:/data $icp_installer:${version} cp -r cluster /data"
sleep 10
lxc exec $1 -- sh -c "ls -al $boot_icp_cluster_dir"

echo ">>>>>>>>>>>>>>>[Copying ICP config data to $1 ... ]"
###############################################################################
## Copy ICP config data to boot node
###############################################################################
# lxc exec $1 -- mkdir -p $boot_icp_cluster_dir
lxc exec $1 -- mkdir -p /root/cluster/
lxc exec $1 -- mkdir -p $boot_icp_bin_dir
lxc exec $1 -- mkdir -p $boot_icp_log_dir
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ./cluster/config.yaml $1/root/cluster/config.yaml
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ./cluster/hosts $1/root/cluster/hosts
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa $1/root/.ssh/id_rsa
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $1/root/.ssh/id_rsa.pub
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/install.sh $1$boot_icp_bin_dir/install.sh
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/install-dbg.sh $1$boot_icp_bin_dir/install-dbg.sh
lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/uninstall.sh $1$boot_icp_bin_dir/uninstall.sh
lxc exec $1 -- sh -c  "cp /root/.ssh/id_rsa $boot_icp_cluster_dir/ssh_key"
lxc exec $1 -- sh -c "cp /root/cluster/hosts $boot_icp_cluster_dir/hosts"
lxc exec $1 -- sh -c "cp /root/cluster/config.yaml $boot_icp_cluster_dir/config.yaml"
lxc exec $1 -- sh -c "ls -al $boot_icp_cluster_dir"

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
echo ">>>>>>>>>>>>>>>[Done initializing LXD node $1]"
###############################################################################
## Start ICP Installation
###############################################################################
echo ">>>>>>>>>>>>>>>[Starting ICP installation now]"
echo ">>>>>>ICP install will complete in 30 mins to 1+ hours depending on your system resource configuration and internet speed.<<<<<"
echo ">>>>>>Install console logs can also be found in '$8-$1/$boot_icp_log_dir' folder.<<<<<"
echo ">>>>>>You can watch your nodes getting updated, from a different VM shell, using command 'watch lxc list $8-'.<<<<<"
if [[ $icp_install_dbg == "true" ]]; then
    lxc exec $1 -- sh -c "$boot_icp_bin_dir/install-dbg.sh $boot_icp_cluster_dir $icp_installer $version $boot_icp_log_dir"
else
    lxc exec $1 -- sh -c "$boot_icp_bin_dir/install.sh $boot_icp_cluster_dir $icp_installer $version $boot_icp_log_dir"
fi
success=$?
if [ $success -eq 0 ]; then
    pod_check_interval=20
    echo ""
    echo ">>>>>>>>>>>>>>>[ICP installation was success]"
    echo ">>>>>>>>>>>>>>>Checking if all pods are up and running ... "
    ## For some reason Completed processes are showing up.
    running=$(lxc exec $2 -- kubectl -s 127.0.0.1:8888 get pods --field-selector=status.phase=Running --no-headers=true --all-namespaces | wc -l)
    completed=$(lxc exec $2 -- kubectl -s 127.0.0.1:8888 get pods --no-headers=true --all-namespaces | grep Completed | wc -l)
    ready=$(($running+$completed))
    total=$(lxc exec $2 -- kubectl -s 127.0.0.1:8888 get pods --no-headers=true --all-namespaces | wc -l)
    if [ "$ready" != "$total" ]; then
        echo ">>>>>>>>>>>>>>>Looks like only $ready/$total pods are Running or Completed."
        echo ">>>>>>>>>>>>>>>Waiting for ICP to settle down. Checking pod status every $pod_check_interval seconds."
        sleep $pod_check_interval
    fi
    while [ "$ready" != "$total" ]; do
      # echo -ne ">>>>>>>>>>>>>>>$ready/$total pods are running ..."\\r
      echo ">>>>>>>>>>>>>>> $ready/$total pods are running ..."
      sleep $pod_check_interval
      running=$(lxc exec $2 -- kubectl -s 127.0.0.1:8888 get pods --field-selector=status.phase=Running --no-headers=true --all-namespaces | wc -l)
      completed=$(lxc exec $2 -- kubectl -s 127.0.0.1:8888 get pods --no-headers=true --all-namespaces | grep Completed | wc -l)
      ready=$(($running+$completed))
    done
    echo ">>>>>>>>>>>>>>>All $ready/$total pods are up and running or completed."
    echo ">>>>>>>>>>>>>>>[If you have not installed kubectl and IBM Cloud CLI (bx) on your host machine, now is good time to do so.]"
    icp_login_sh_file=icp-login-$version-$edition.sh
    echo "Next, once you download ICP CLI following are some helpful commands for your environment setup and use."
    echo "Following commands will be saved in '$icp_login_sh_file' file for login easeness and cluster config."
    echo "##Contents of this file will be replaced on next successful install" | tee $icp_login_sh_file
    echo "## Default values will be replaced with values from terraform variables (if changed)" | tee -a $icp_login_sh_file
    echo "# Run following command once and only if ICP plugin is not installed for IBM Cloud CLI"  | tee -a $icp_login_sh_file
    echo "bx plugin install icp-linux-amd64" | tee -a $icp_login_sh_file
    echo "# Validate ICP CLI plugin install" | tee -a $icp_login_sh_file
    echo "bx plugin show icp" | tee -a $icp_login_sh_file
    echo "# Login to ICP CE" | tee -a $icp_login_sh_file
    if [[ $version == "2.1.0.1" ]]; then
        # older version
        echo "bx pr login -a https://$master_ip:8443 -u admin -p $default_admin_password -c id-icp-account --skip-ssl-validation" | tee -a $icp_login_sh_file
    else
        ## 2.1.0.2+
        echo "bx pr login -a https://$master_ip:8443 -u admin -p $default_admin_password -c id-$cluster_name-account --skip-ssl-validation" | tee -a $icp_login_sh_file
    fi
    ### for some reason non-sudo command is not working
    echo "# Cluster config " | tee -a $icp_login_sh_file
    echo "bx pr cluster-config $cluster_name" | tee -a $icp_login_sh_file
    echo "# Validate kubectl is working" | tee -a $icp_login_sh_file
    echo "kubectl get nodes" | tee -a $icp_login_sh_file
    echo "# Information about clusters" | tee -a $icp_login_sh_file
    echo "bx pr clusters" | tee -a $icp_login_sh_file
    echo "# Get cluster specific info" | tee -a $icp_login_sh_file
    echo "bx pr cluster-get $cluster_name" | tee -a $icp_login_sh_file
    echo ">>>>>>>>>>>>>>>[INSTALL COMPLETE - ICP ON LINUX CONTAINER IS READY TO USE]"
else
    echo ""
    echo "INSTALL FAILED - $success"
    echo "echo 'INSTALL FAILED - $success'" | tee icp-login.sh &> /dev/null
fi
