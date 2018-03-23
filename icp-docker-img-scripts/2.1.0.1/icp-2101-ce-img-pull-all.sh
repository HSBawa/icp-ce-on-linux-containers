###############################################################################
### ICP-CE 2.1.0.1 key Docker Image Pull script
### https://hub.docker.com/u/ibmcom/
###############################################################################
###############################################################################
# Boot
###############################################################################
docker pull ibmcom/icp-inception:2.1.0.1

###############################################################################
# Master
###############################################################################
docker pull ibmcom/icp-catalog-ui:2.1.0.1
docker pull ibmcom/iam-policy-administration:2.1.0.1
docker pull ibmcom/icp-datastore:2.1.0.1
docker pull ibmcom/icp-platform-ui:2.1.0.1
docker pull ibmcom/iam-policy-decision:2.1.0.1
docker pull ibmcom/iam-token-service:2.1.0.1
docker pull ibmcom/unified-router:2.1.0.1
docker pull ibmcom/icp-platform-api:2.1.0.1
docker pull ibmcom/icp-identity-provider:2.1.0.1
docker pull ibmcom/icp-image-manager:2.1.0.1
docker pull ibmcom/icp-router:2.1.0.1
docker pull ibmcom/icp-platform-auth:2.1.0.1
docker pull ibmcom/icp-identity-manager:2.1.0.1
docker pull ibmcom/icp-helm-api:2.1.0.1
docker pull ibmcom/icp-helm-repo:2.1.0.1
docker pull ibmcom/service-catalog-service-catalog:v0.1.2
docker pull ibmcom/rescheduler:v0.5.2
docker pull ibmcom/tiller:v2.6.0
docker pull ibmcom/calico-policy-controller:v0.7.0
docker pull ibmcom/calico-ctl:v1.4.0
docker pull ibmcom/heapster:v1.4.0
docker pull ibmcom/k8s-dns-sidecar:1.14.4
docker pull ibmcom/k8s-dns-kube-dns:1.14.4
docker pull ibmcom/k8s-dns-dnsmasq-nanny:1.14.4
docker pull ibmcom/etcd:v3.1.5
docker pull ibmcom/mariadb:10.1.16
docker pull ibmcom/registry:2
docker pull ibmcom/kubernetes:v1.8.3
docker pull ibmcom/metering-reader:2.1.0.1
docker pull ibmcom/calico-node:v2.4.1
docker pull ibmcom/calico-cni:v1.10.0
docker pull ibmcom/filebeat:5.5.1
docker pull ibmcom/node-exporter:v0.14.0
docker pull ibmcom/pause:3.0

###############################################################################
# Management
###############################################################################
docker pull ibmcom/icp-router:2.1.0.1
docker pull ibmcom/metering-data-manager:2.1.0.1
docker pull ibmcom/metering-server:2.1.0.1
docker pull ibmcom/metering-ui:2.1.0.1
docker pull ibmcom/indices-cleaner:0.2
docker pull ibmcom/icp-initcontainer:1.0.0
docker pull ibmcom/kube-state-metrics:v1.0.0
docker pull ibmcom/grafana:4.4.3
docker pull ibmcom/curl:3.6
docker pull ibmcom/logstash:5.5.1
docker pull ibmcom/elasticsearch:5.5.1
docker pull ibmcom/alertmanager:v0.8.0
docker pull ibmcom/prometheus:v1.7.1
docker pull ibmcom/configmap-reload:v0.1
docker pull ibmcom/collectd-exporter:0.3.1
docker pull ibmcom/kubernetes:v1.8.3
docker pull ibmcom/metering-reader:2.1.0.1
docker pull ibmcom/calico-node:v2.4.1
docker pull ibmcom/calico-cni:v1.10.0
docker pull ibmcom/filebeat:5.5.1
docker pull ibmcom/node-exporter:v0.14.0
docker pull ibmcom/pause:3.0

###############################################################################
# Proxy
###############################################################################
docker pull  ibmcom/nginx-ingress-controller:0.9.0-beta.13
docker pull ibmcom/defaultbackend:1.2
docker pull ibmcom/kubernetes:v1.8.3
docker pull ibmcom/metering-reader:2.1.0.1
docker pull ibmcom/calico-node:v2.4.1
docker pull ibmcom/calico-cni:v1.10.0
docker pull ibmcom/filebeat:5.5.1
docker pull ibmcom/node-exporter:v0.14.0
docker pull ibmcom/pause:3.0

###############################################################################
# Worker
###############################################################################
docker pull ibmcom/kubernetes:v1.8.3
docker pull ibmcom/metering-reader:2.1.0.1
docker pull ibmcom/calico-node:v2.4.1
docker pull ibmcom/calico-cni:v1.10.0
docker pull ibmcom/filebeat:5.5.1
docker pull ibmcom/node-exporter:v0.14.0
docker pull ibmcom/pause:3.0
