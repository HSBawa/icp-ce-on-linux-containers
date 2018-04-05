#!/bin/bash
echo "Setting up Docker Secret for ICP Clouad Automation Manager. This script assumes that 'kubectl' is configured for your ICP Install"
echo ""
echo -n "Enter secretname: "
read secretname
echo -n "Enter Docker username: "
read docker_username
echo -n "Enter Docker password/API-Key: "
read docker_password
echo -n "Enter Docker email: "
read docker_email
echo -n "Generating secret ... "

kubectl create secret docker-registry $secretname --docker-username=$docker_username --docker-password=$docker_password --docker-email=$docker_email -n services
