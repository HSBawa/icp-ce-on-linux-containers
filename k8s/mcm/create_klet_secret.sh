#!/bin/bash

if [[ -z $1 ]]; then 
  echo "Cluster IP/HOST is required."
  echo "Command: create_klet_secret.sh <icp_master_ip> <klet_tiller_secret_name>"
  exit -1;
fi 

if [[ -z $2 ]]; then 
  echo "Klusterlet tiller secret name is required."
  echo "Command: create_klet_secret.sh <icp_master_ip> <klet_tiller_secret_name>"
  exit -2;
fi 
echo "Login into cluster: $1 "
cloudctl login -a https://$1:8443 -n kube-system --skip-ssl-validation
echo "Creating secret: $2 "
kubectl create secret tls $2 --cert ~/.helm/cert.pem --key ~/.helm/key.pem -n kube-system
echo "Done"
