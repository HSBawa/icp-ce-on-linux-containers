#!/bin/bash
echo "This will install LXD on Ubuntu"
echo "NOTE: This script uses APT which will install 3.0.1"
echo "For higher version of LXD, use SNAP instead of APT"
apt-get update
#apt-get -y -t xenial-backports install lxd
snap install lxd --channel=stable
apt-get install -y thin-provisioning-tools
echo "LXD client version: $(lxc --version)"
echo "LXD server version: $(lxd --version)"
