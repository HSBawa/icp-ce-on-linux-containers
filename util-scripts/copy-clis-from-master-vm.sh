#!/bin/bash
icp_master_lxd_node="dev-master-0"
temp_dir="./bin"
target_dir="/usr/local/bin"

if [[ ! -z $1 ]]; then
   icp_master_lxd_node=$1
fi


function download_kubectl(){
    ## Contents of this file will be replaced on next successful install
    ## Default values will be replaced with values from terraform variables (if changed)
    echo -n "Downloading lastet kubectl ... "
    curl -sq -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && sudo mv kubectl /usr/local/bin && sudo chmod +x /usr/local/bin/kubectl
    echo "Done"
    echo "Install location: $(which kubectl)"
    echo "$(/usr/local/bin/kubectl version --client=true --short=true)"
    echo ""

}

function copy_icp_helm(){
    echo "Pulling 'helm' from master node : $icp_master_lxd_node"
    lxc file pull $icp_master_lxd_node$target_dir/helm $temp_dir
    chmod +x $temp_dir/helm
    echo "Copying ICP helm to $target_dir as helm-icp"
    sudo cp $temp_dir/helm $target_dir/helm-icp
    echo "Install location: $(which helm-icp)"
    loc=$(which helm-icp)
    echo ""
}

function copy_icp_cloudctl(){
    echo "Pulling 'cloudctl' from master node : $icp_master_lxd_node"
    lxc file pull $icp_master_lxd_node$target_dir/cloudctl $temp_dir
    chmod +x $temp_dir/cloudctl
    echo "Copying ICP cloudctl to $target_dir"
    sudo cp $temp_dir/cloudctl $target_dir
    echo "Install location: $(which cloudctl)"
    echo ""

}

mkdir $temp_dir
download_kubectl
copy_icp_helm
copy_icp_cloudctl
