###############################################################################
# ICP-CE 2.1.0.2 Proxy Node Images for Tar Archive
###############################################################################
docker save -o icp-ce-2102-proxy.tar ibmcom/metering-reader:2.1.0.2 ibmcom/kubernetes:v1.9.1 ibmcom/nginx-ingress-controller:0.9.0 ibmcom/calico-node:v2.6.6 ibmcom/icp-initcontainer:1.0.0 ibmcom/calico-cni:v1.11.2 ibmcom/filebeat:5.5.1 ibmcom/defaultbackend:1.2 ibmcom/pause:3.0
