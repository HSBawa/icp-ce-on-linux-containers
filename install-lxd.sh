#!/bin/bash
apt-get update
apt-get -y -t xenial-backports install lxd
apt-get install -y thin-provisioning-tools
echo "LXD client version: $(lxc --version)"
echo "LXD server version: $(lxd --version)"
