#!/bin/bash

echo ">>>>>>>>>>>>>>>[Backing up SSH Keys on local host ... ]"
mv ./ssh-keys/id_rsa ./ssh-keys/id_rsa.bak &> /dev/null
mv ./ssh-keys/id_rsa.pub ./ssh-keys/id_rsa.pub.bak &> /dev/null
echo ""

echo ">>>>>>>>>>>>>>>[Backing up hosts file on local host ... ]"
mv ./cluster/hosts ./cluster/hosts.bak &> /dev/null
echo ""

echo ">>>>>>>>>>>>>>>[Backing up etc-hosts file on local host ... ]"
mv ./cluster/etc-hosts ./cluster/etc-hosts.bak &> /dev/null
echo ""

echo ">>>>>>>>>>>>>>>[Backing up config file on local host ... ]"
mv ./cluster/config.yaml ./cluster/config.yaml.bak &> /dev/null
echo ""
