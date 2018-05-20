#!/bin/bash
echo "********************************************************"
echo "This script assumes that ICP config context is set"
echo "********************************************************"
echo ""
NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-release-ibm-jenkins-d)
NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo "Jenkins admin console URL : http://$NODE_IP:$NODE_PORT/login"
echo ""
PASSWORD=$(kubectl get secret --namespace default my-release-ibm-jenkins-d -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)
echo "Console default username/password: admin/$PASSWORD"
echo ""
