#!/bin/bash
#############################################################################
## This script prepares boot node for ICP Installation
#############################################################################
env="$1"
version="$2"
edition="$3"
icp_installer=$4
install_dbg=$5
boot_node_grep_key=$6
cluster_name=$7
default_namespace=$8
admin_user=$9
admin_pass=${10}

boot_icp_dir="/opt/icp-$version-$edition"
boot_icp_cluster_dir="$boot_icp_dir/cluster"
boot_icp_bin_dir="$boot_icp_dir/bin"
boot_icp_log_dir="$boot_icp_dir/log"
boot_vm="$env-master-0"
master_ip="10.50.50.101"
cliname=cloudctl
download_clis_file="download_cloudctl_hem_kubectl.sh"
download_clis_file_tmpl="./util-scripts/download_cloudctl_helm_kubectl.sh.tmpl"

if [[ -z "$env" ]]; then
    version="dev"
fi

if [[ -z "$icp_installer" ]]; then
    icp_installer="ibmcom/icp-inception"
fi

if [[ -z "$install_dbg" ]]; then
    install_dbg="0"
fi

if [[ -z "$version" ]]; then
    version="3.1.0"
fi

if [[ -z "$edition" ]]; then
    version="ce"
fi



function setup_inception_image(){
    if [[ -z "$icp_installer" ]]; then
        icp_installer="ibmcom/icp-inception"
    fi
    echo "Pulling $icp_installer:${version}"
    lxc exec $boot_vm -- sh -c "docker pull $icp_installer:${version}"
    echo "Extracting configuration data ... "
    lxc exec $boot_vm -- sh -c "docker run -e LICENSE=accept -v $boot_icp_dir:/data $icp_installer:${version} cp -r cluster /data"
    sleep 10
    lxc exec $boot_vm -- sh -c "ls -al $boot_icp_cluster_dir"
}

function copy_config_files(){
    lxc exec $boot_vm -- mkdir -p $boot_icp_cluster_dir
    lxc exec $boot_vm -- mkdir -p /root/cluster/
    lxc exec $boot_vm -- mkdir -p $boot_icp_bin_dir
    lxc exec $boot_vm -- mkdir -p $boot_icp_log_dir
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ./cluster/config.yaml $boot_vm/root/cluster/config.yaml
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0644" ./cluster/hosts $boot_vm/root/cluster/hosts
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa $boot_vm/root/.ssh/id_rsa
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0400" ./ssh-keys/id_rsa.pub $boot_vm/root/.ssh/id_rsa.pub
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/install.sh $boot_vm$boot_icp_bin_dir/install.sh
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/install-dbg.sh $boot_vm$boot_icp_bin_dir/install-dbg.sh
    lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ./cluster/uninstall.sh $boot_vm$boot_icp_bin_dir/uninstall.sh
    lxc exec $boot_vm -- sh -c  "cp /root/.ssh/id_rsa $boot_icp_cluster_dir/ssh_key"
    lxc exec $boot_vm -- sh -c "cp /root/cluster/hosts $boot_icp_cluster_dir/hosts"
    lxc exec $boot_vm -- sh -c "cp /root/cluster/config.yaml $boot_icp_cluster_dir/config.yaml"
    lxc exec $boot_vm -- sh -c "ls -al $boot_icp_cluster_dir"
}


function create_cli_download_script(){
    sed  's/@@MASTER_NODE@@/'"$boot_vm"'/g' <$download_clis_file_tmpl >$download_clis_file
}

function get_boot_vm_name(){
    boot_vm="$(lxc list ${env}- -c n --format=csv | grep $boot_node_grep_key)"
    echo "Boot VM is: $boot_vm"
    master_ip=$(lxc exec  $boot_vm -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
}

function run_install(){
    if [[ $install_dbg == "1" ]]; then
        echo "Running install in debug mode"
        lxc exec $boot_vm -- sh -c "$boot_icp_bin_dir/install-dbg.sh $boot_icp_cluster_dir $icp_installer $version $boot_icp_log_dir"
    else
        echo "Running install in non-debug mode"
        lxc exec $boot_vm -- sh -c "$boot_icp_bin_dir/install.sh $boot_icp_cluster_dir $icp_installer $version $boot_icp_log_dir"
    fi

    success=$?
    if [ $success -eq 0 ]; then
        pod_check_interval=20
        echo ""
        echo ">>>>>>>>>>>>>>>[ICP installation was success]"
        if [[ $version =~ ^("3.1.0") ]]; then
            echo ">>>>>>>>>>>>>>>>>>Creating shell script ($download_clis_file) to download: cloudctl, helm and kubectl<<<<<<<<<<<<<<<<<<"
            create_cli_download_script
            echo "Done"
            echo ""
            icp_login_sh_file=icp-login-$version-$edition.sh
            echo ">>>>>>>>>>>>>>>>>Creating shell shell Script for ICP Login ease<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo "#!/bin/bash" | tee $icp_login_sh_file
            echo "" | tee -a $icp_login_sh_file
            echo "## Following commands will be saved in '$icp_login_sh_file' file for login easeness and cluster config."
            echo "####################################################################################################" | tee -a $icp_login_sh_file
            echo "## Contents of this file will be replaced on next successful install"  | tee -a $icp_login_sh_file
            echo "## Default values will be replaced with values from terraform variables (if changed)"  | tee -a $icp_login_sh_file
            echo "## Cluster name is : $cluster_name"  | tee -a $icp_login_sh_file
            echo "####################################################################################################" | tee -a $icp_login_sh_file
            echo "echo \"Login to ICP CE\"" | tee -a $icp_login_sh_file
            echo "echo  \"\"" | tee -a $icp_login_sh_file
            echo "cloudctl_loc=\$(command -v $cliname)"  | tee -a $icp_login_sh_file
            echo "if [[ -z \$cloudctl_loc ]]; then " | tee -a $icp_login_sh_file
            echo "   echo \"********************************************************************************************\"" | tee -a $icp_login_sh_file
            echo "   echo \"Required '$cliname' CLI does not exit. Download using $download_clis_file shell script or following commands\"" | tee -a $icp_login_sh_file
            echo "   echo \"sudo curl -kLo /usr/local/bin/$cliname https://$master_ip:8443/api/cli/$cliname-linux-amd64\"" | tee -a $icp_login_sh_file
            echo "   echo \"sudo chmod +x /usr/local/bin/$cliname\"" | tee -a $icp_login_sh_file
            echo "   echo \"********************************************************************************************\"" | tee -a $icp_login_sh_file
            echo "   echo \"\"" | tee -a $icp_login_sh_file
            echo "   exit " | tee -a $icp_login_sh_file
            echo "fi" | tee -a $icp_login_sh_file
            echo "echo  \"\"" | tee -a $icp_login_sh_file
            echo "echo \"[If you have issues executing $cliname command, clean up ~/.cloudctl and ~/.helm]\"" | tee -a $icp_login_sh_file
            echo "echo  \"\"" | tee -a $icp_login_sh_file
            echo "$cliname login -a https://$master_ip:8443 -u $admin_user -p $admin_pass -c id-$cluster_name-account -n $default_namespace  --skip-ssl-validation" | tee -a $icp_login_sh_file
            echo "$cliname cm nodes" | tee -a $icp_login_sh_file
            echo "$cliname api" | tee -a $icp_login_sh_file
            echo "$cliname target" | tee -a $icp_login_sh_file
            echo "$cliname config --list" | tee -a $icp_login_sh_file
            echo "$cliname catalog repos" | tee -a $icp_login_sh_file
            echo "$cliname iam roles" | tee -a $icp_login_sh_file
            echo "$cliname iam services" | tee -a $icp_login_sh_file
            echo "$cliname iam service-ids" | tee -a $icp_login_sh_file
            echo "$cliname pm passwword-rules $cluster_name $default_namespace" | tee -a $icp_login_sh_file
            echo "$cliname catalog charts" | tee -a $icp_login_sh_file
        fi
        ### for some reason non-sudo command is not working
        echo ""
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
        echo "|*|*|*|*|*|*|*|*|*| |I|n|s|t|a|l|l| |C|o|m|p|l|e|t|e| |*|*|*|*|*|*|*|*|*|*|*|*|"
        echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
        echo "+-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+ +-+-+-+"
        echo "|I|C|P| |o|n| |L|i|n|u|x| |C|o|n|t|a|i|n|e|r|s| |i|s| |r|e|a|d|y| |t|o| |u|s|e|"
        echo "+-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+ +-+-+-+"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    else
        echo ""
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!INSTALL FAILED - $success !!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

    fi

}


echo ">>>>>>>>>>>>>>>[Retrieving boot node information ...] "
get_boot_vm_name
echo "Boot Node name is: $boot_vm"
echo ""
echo ">>>>>>>>>>>>>>>[Setting up inception image on $boot_vm ...] "
setup_inception_image
echo ""
echo ">>>>>>>>>>>>>>>[Copying config file to $boot_vm for installation  ...] "
copy_config_files
echo ""
echo ">>>>>>>>>>>>>>>[Starting ICP install on $boot_vm ...] "
run_install
echo ""
