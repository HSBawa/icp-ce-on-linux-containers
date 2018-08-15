#!/bin/bash
apt -y -t xenial-backports install lxd
echo "LXD client version: $(lxc --version)"
echo "LXD server version: $(lxd --version)"
