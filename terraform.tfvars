env_prefix="dev"
## Linux Container image for ICP. xenial and artful amd64
lxd_image_name="xenial-container-for-icp"
#lxd_image_name="artful-amd64-container-for-icp"
#lxd_image_name="bionic-container-for-icp"
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
va_host_num=204
worker_1_host_num=205
worker_2_host_num=206
worker_3_host_num=207
## in secure environment pass this as terraform command parameter
admin_pass="admin_0000"
## You can disable the following management services: service-catalog, metering, monitoring, va
disabled_management_services="[]"
# disabled_management_services="[\\\"va\\\",\\\"metering\\\",\\\"monitoring\\\"]"
#disabled_management_services="[\\\"metering\\\",\\\"monitoring\\\"]"
install_kibana="true"
cluster_name="devicpcluster"
cluster_domain="icpcluster.local"
cluster_CA_domain="{{ cluster_name }}.icp"
# icp_tag="2.1.0.1"
icp_tag="2.1.0.2"
#icp_tag="2.1.0.3"
icp_edition="ce"
icp_installer="ibmcom/icp-inception"
### Debug Install Use Only (true or false)
icp_install_dbg="false"

## Following options are to load docker tar images
# option to load docker tar images: true or false only
icp_docker_tar="false"
# Provide absolute path on respective nodes.
# Following example uses shared folder (host)
icp_docker_tar_boot_path="/share/icp2102ce/icp-ce-2102-boot.tar"
icp_docker_tar_master_path="/share/icp2102ce/icp-ce-2102-master.tar"
icp_docker_tar_mgmt_path="/share/icp2102ce/icp-ce-2102-mgmt.tar"
icp_docker_tar_va_path="/share/icp2102ce/icp-ce-2102-va.tar"
icp_docker_tar_proxy_path="/share/icp2102ce/icp-ce-2102-proxy.tar"
icp_docker_tar_worker_path="/share/icp2102ce/icp-ce-2102-worker.tar"

### Followig options are for org private respoitory use only
# Private Registry values: true or false
private_registry_enabled="false"
#Don't use empty values
private_registry_docker_username="dummy"
private_registry_docker_password="dummy"
private_registry_server="dummy"
private_image_repo="dummy"
private_image_repo_version="dummy"
private_installer="dummy"
