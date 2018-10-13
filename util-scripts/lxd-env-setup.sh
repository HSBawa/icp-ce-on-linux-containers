#!/bin/bash

linux="xenial"


if [[ $1 =~ ^("xenial"|"bionic") ]]; then
   linux=$1
   echo "User provided LXD base image option is: $linux"   
else 
   echo "Invalid parameters. Default LXD bse image is set to: $linux"
fi

echo "### NOTE: THIS SCRIPT IS WORK IN PROGRESSS"
echo "### PLEASE REVIEW AND UPDATE FOR YOUR USE"
echo "Install will start in 10 secs ... CTRL-C to cancel"
sleep 10

function create_lxcshare_folder(){
  #### Run this script as sudo/root
  mkdir -p /media/lxcshare
}

function install_docker(){
  bash "./docker/install-docker.sh"
}

function install_lxd(){
   bash "./lxd-setup/install-lxd-on-ubuntu-w-apt.sh"
}

function install_terraform_and_packer_and_plugin(){
   ## Install Terraform and Packer. Make sure to update latest version number
   bash "./lxd-setup/terraform-packer/install-terra-n-packer.sh"
   ## Install Terraform Plugin for LXD. Make sure to get latest
   bash "./lxd-setup/terraform-plugin/install-terraform-plugin-for-lxd.sh"   
}

function init_lxd(){
  ## LVM Thin Provisioning
  # Creates new storage of type LVM pool-name=default, network-bridge=lxdbr0, lxd-profile=default
  sudo cat ./lxd-setup/init-pre-seed/lxd-init-preseed-lvm-default.yaml | lxd init --preseed
  # Creates new storage of type LVM pool-name=demo, network-bridge=demobr0, lxd-profile=demo
  #sudo cat ./lxd-setup/init-pre-seed/lxd-init-preseed-lvm-demo.yaml | lxd init --preseed
  # Creates new storage of type LVM pool-name=icp, network-bridge=icpbr0, lxd-profile=icp
  #sudo cat ./lxd-setup/init-pre-seed/lxd-init-preseed-lvm-demo.yaml | lxd init --preseed
}

function create_image_for_icp(){
  if [[ $1 =~ ^("bionic") ]]; then
     packer validate ./lxd-setup/images/xenial-packer-lxd-image-lvm-for-bionic-host
     packer build    ./lxd-setup/images/xenial-packer-lxd-image-lvm-for-bionic-host
  else
     packer validate ./lxd-setup/images/xenial-packer-lxd-image-lvm
     packer build    ./lxd-setup/images/xenial-packer-lxd-image-lvm  
  fi
}

create_lxcshare_folder
install_lxd
init_lxd
install_docker
install_terraform_and_packer_and_plugin
create_image_for_icp $linux
