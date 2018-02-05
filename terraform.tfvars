env_prefix="dev"
## Linux Container image for ICP. xenial and artful amd64
lxd_image_name="xenial-container-for-icp"
#lxd_image_name="artful-amd64-container-for-icp"
remote_name="local"
## device type: network interface
net_device_type="nic"
## nic type values: physical, bridged, macvlan, p2p and sriov
net_device_nic_type="bridged"
## Device name
net_device_name="eth0"
## Network name: $env_prefix$network_name
network_name = ["br0"]
## Disable IPV6
ipv6_cidr = ["none"]
## Provide IPV4 subnets
ipv4_cidr = ["10.50.50.1/24"]
ipv4_nat="true"
ipv6_nat="false"
boot_host_num=200
master_host_num=201
proxy_host_num=202
mgmt_host_num=203
worker_1_host_num=204
worker_2_host_num=205
worker_3_host_num=206
## in secure environment pass this as terraform command parameter
admin_pass="admin_0000"
## You can disable the following management services: ["service-catalog","metering","monitoring"]
# disabled_management_services="[]"
disabled_management_services="[\\\"metering\\\",\\\"monitoring\\\"]"
cluster_name="devicpcluster"
cluster_domain="icpcluster.local"
cluster_CA_domain="{{ cluster_name }}.icp"
