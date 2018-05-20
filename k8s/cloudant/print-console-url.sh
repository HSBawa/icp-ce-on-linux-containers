#!/bin/bash
echo "********************************************************"
echo "This script assumes that ICP config context is set"
echo "********************************************************"
echo ""
NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-cloudant-ibm-cloudant-dev)
NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo "Console URL : http://$NODE_IP:$NODE_PORT/dashboard.html"
echo ""
echo "Console default username/password: admin/pass"
echo ""
