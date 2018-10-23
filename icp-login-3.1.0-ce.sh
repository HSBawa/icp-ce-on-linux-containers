#!/bin/bash

####################################################################################################
## Contents of this file will be replaced on next successful install
## Default values will be replaced with values from terraform variables (if changed)
## Cluster name is : devicpcluster
####################################################################################################
echo "Login to ICP CE"
echo  ""
cloudctl_loc=$(command -v cloudctl)
if [[ -z $cloudctl_loc ]]; then
   echo "********************************************************************************************"
   echo "Required 'cloudctl' CLI does not exit. Download using download_cloudctl_helm_kubectl.sh shell script or following commands"
   echo "sudo curl -kLo /usr/local/bin/cloudctl https://10.50.50.101:8443/api/cli/cloudctl-linux-amd64"
   echo "sudo chmod +x /usr/local/bin/cloudctl"
   echo "********************************************************************************************"
   echo ""
   exit
fi
echo  ""
echo "[If you have issues executing cloudctl command, clean up ~/.cloudctl and ~/.helm]"
echo  ""
cloudctl login -a https://10.50.50.101:8443 -u admin -p admin_1111 -c id-devicpcluster-account -n default  --skip-ssl-validation
cloudctl cm nodes
cloudctl api
cloudctl target
cloudctl config --list
cloudctl catalog repos
cloudctl iam roles
cloudctl iam services
cloudctl iam service-ids
cloudctl pm password-rules devicpcluster default
cloudctl catalog charts
