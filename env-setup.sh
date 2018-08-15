#!/bin/bash
#### Run this script as sudo/root
mkdir -p /media/lxcshare
eval "./install-lxd.sh"
eval "./install-terra-n-packer.sh"
eval "./install-terra-lxd.sh"
eval "./install-docker.sh
## LVM Thin
#cat lxd-init-preseed-lvm.yaml | lxd init --preseed
## BTRFS
#cat lxd-init-preseed.yaml | lxd init --preseed

