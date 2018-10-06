#!/bin/bash
#### Run this script as sudo/root
mkdir -p /media/lxcshare
eval "./docker/install-docker.sh"
eval "./lxd-setup/install-lxd-on-ubuntu-w-apt.sh"
## Install Terraform and Packer. Make sure to update latest version number
eval "./lxd-setup/terraform-packer/install-terra-n-packer.sh"
## Install Terraform Plugin for LXD. Make sure to get latest
eval "./lxd-setup/terraform-plugin/install-terraform-plugin-for-lxd.sh"
## Use following for Bionic host only. Requires Internet Access
eval "packer validate ./lxd-setup/images/xenial-packer-lxd-image-lvm-for-bionic-host"
eval "packer build ./lxd-setup/images/xenial-packer-lxd-image-lvm-for-bionic-host"
## Use following for Xenial host only
# eval "./packer validate ./lxd-setup/images/xenial-packer-lxd-image-lvm"

## LVM Thin Provisioning
# Creates new storage of type LVM pool-name=default, network-bridge=lxdbr0, lxd-profile=default
sudo cat ./lxd-setup/init-pre-seed/lxd-init-preseed-lvm-default.yaml | lxd init --preseed
# Creates new storage of type LVM pool-name=demo, network-bridge=demobr0, lxd-profile=demo
#sudo cat ./lxd-setup/init-pre-seed/lxd-init-preseed-lvm-demo.yaml | lxd init --preseed
# Creates new storage of type LVM pool-name=icp, network-bridge=icpbr0, lxd-profile=icp
#sudo cat ./lxd-setup/init-pre-seed/lxd-init-preseed-lvm-demo.yaml | lxd init --preseed
