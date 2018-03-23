###############################################################################
# ICP-CE 2.1.0.1 Worker Node Images for Tar Archive
###############################################################################
docker save -o icp-ce-2101-common.tar ibmcom/kubernetes:v1.8.3 ibmcom/metering-reader:2.1.0.1 ibmcom/calico-node:v2.4.1 ibmcom/calico-cni:v1.10.0 ibmcom/filebeat:5.5.1 ibmcom/node-exporter:v0.14.0 ibmcom/pause:3.0
