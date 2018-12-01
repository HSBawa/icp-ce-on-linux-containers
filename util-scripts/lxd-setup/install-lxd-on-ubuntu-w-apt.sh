#!/bin/bash
echo "This will install latest stable LXD using SNAP on Ubuntu"
apt-get update
#apt-get -y -t xenial-backports install lxd
#snap install lxd --channel=stable
apt-get install -y thin-provisioning-tools
echo "LXD client version: $(lxc --version)"
echo "LXD server version: $(lxd --version)"
