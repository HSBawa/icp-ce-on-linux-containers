#!/bin/bash
echo "********************************************************"
echo "This script assumes that ICP config context is set"
echo "********************************************************"
echo ""
NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-liberty-ibm-open-libe-np)
NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo "Liberty page URL : http://$NODE_IP:$NODE_PORT"
echo "**Note: Change to Proxy IP, if the script retrieved IP does not work"
echo ""
