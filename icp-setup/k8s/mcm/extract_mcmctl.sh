#!/bin/bash

cluster_CA_domain="devicpcluster.icp"

if [[ -z $1 ]]; then
   echo "No user provided input. Using default cluster_CA_domain: ${cluster_CA_domain}"
else
   cluster_CA_domain=$1
   echo "Using user provided cluster_CA_Domain: ${cluster_CA_domain}"
fi

if [[ "$OSTYPE" == "linux-gnu" ]]; then
   docker run -e LICENSE=accept -v $(pwd):/data ${cluster_CA_domain}:8500/kube-system/mcmctl:3.1.1 cp mcmctl-linux-amd64 /data/mcmctl   
elif [[ "$OSTYPE" == "darwin"* ]]; then
   docker run -e LICENSE=accept -v $(pwd):/data ${cluster_CA_domain}:8500/kube-system/mcmctl:3.1.1 cp mcmctl-darwin-amd64 /data/mcmctl
elif [[ "$OSTYPE" == "ppc64"* ]]; then
   docker run -e LICENSE=accept -v $(pwd):/data ${cluster_CA_domain}:8500/kube-system/mcmctl:3.1.1 cp mcmctl-linux-ppc64le /data/mcmctl
else
   echo "Not implemented for OS: $OSTYPE"
fi
