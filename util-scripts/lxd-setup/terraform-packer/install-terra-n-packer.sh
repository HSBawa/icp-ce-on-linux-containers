#!/bin/bash

apt-get update
apt install -y curl unzip

PACKER_VERSION=1.2.5
TERRAFORM_VERSION=0.11.7

PACKER_ZIP="packer_${PACKER_VERSION}_linux_amd64.zip"
PACKER_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/${PACKER_ZIP}"

TERRAFORM_ZIP=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}"

echo ""
echo "Installing packer ..."
curl -fso /tmp/${PACKER_ZIP} ${PACKER_URL}
unzip /tmp/${PACKER_ZIP} -d /usr/local/bin
chmod +x /usr/local/bin/packer

echo ""
echo "Installing terraform ..."
curl -fso /tmp/${TERRAFORM_ZIP} ${TERRAFORM_URL}
unzip /tmp/${TERRAFORM_ZIP} -d /usr/local/bin
chmod +x /usr/local/bin/terraform

echo "$(which terraform)"
echo "$(which packer)"
