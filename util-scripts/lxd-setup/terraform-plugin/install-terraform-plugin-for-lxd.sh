#!/bin/bash

TERRA_LXD_VERSION="v1.1.3"
TERRA_LXD_ZIP="terraform-provider-lxd_${TERRA_LXD_VERSION}_linux_amd64.zip"
TERRA_LXD_URL="https://github.com/sl1pm4t/terraform-provider-lxd/releases/download/${TERRA_LXD_VERSION}/${TERRA_LXD_ZIP}"
TERRA_LXD_PLUGIN_LOC="${HOME}/.terraform.d/plugins/linux_amd64"
rm /tmp/${TERRA_LXD_ZIP}
wget ${TERRA_LXD_URL} -O  /tmp/${TERRA_LXD_ZIP} -q --show-progress
mkdir -p ${TERRA_LXD_PLUGIN_LOC}
unzip /tmp/${TERRA_LXD_ZIP} -d ${TERRA_LXD_PLUGIN_LOC}
echo "$(ls -al ${TERRA_LXD_PLUGIN_LOC})"
