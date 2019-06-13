#!/bin/bash

####################################################################################################
## Contents of this file "icp-login.sh" will be replaced on next successful install
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
echo "cloudctl login -a https://10.50.50.101:8443 -u admin -p ****** -c id-devicpcluster-account -n default --skip-ssl-validation"
cloudctl login -a https://10.50.50.101:8443 \
               -u admin \
               -p ********** \
               -c id-devicpcluster-account \
               -n default \
               --skip-ssl-validation
 echo  ""
 echo "cloudctl api : "
 cloudctl api
 echo  ""
 echo "cloudctl target : "
 cloudctl target
 echo  ""
 echo "cloudctl config --list : "
 cloudctl config --list
 echo  ""
 echo "cloudctl catalog repos : "
 cloudctl catalog repos
 echo  ""
 echo "cloudctl iam roles : "
 cloudctl iam roles
 echo  ""
 echo "cloudctl iam services : "
 cloudctl iam services
 echo  ""
 echo "cloudctl iam service-ids : "
 cloudctl iam service-ids
 echo  ""
 echo "cloudctl catalog charts : "
 cloudctl catalog charts
