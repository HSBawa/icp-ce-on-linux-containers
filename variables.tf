variable "ipv4_cidr"{type="list"}
variable "ipv6_cidr"{type="list"}
variable "ipv4_nat"{default="true"}
variable "ipv6_nat"{default="false"}
variable "network_name"{type="list"}
variable "env_prefix"{}
variable "lxd_image_name"{}
variable "remote_name"{default="local"}
variable "boot_host_num"{}
variable "master_host_num"{}
variable "proxy_host_num"{}
variable "mgmt_host_num"{}
variable "worker_1_host_num"{}
variable "worker_2_host_num"{}
variable "worker_3_host_num"{}
variable "net_device_type"{}
variable "net_device_nic_type"{}
variable "net_device_name"{}
variable "admin_pass"{}
variable "disabled_management_services" {default="[]"}
variable "cluster_name" {}
variable "cluster_domain" {}
variable "cluster_CA_domain" {}
variable "install_kibana" {}
variable "icp_tag" {}
variable "icp_edition" {}
variable "icp_installer" {}
variable "private_registry_enabled" {}
variable "private_registry_server" {}
variable "private_image_repo" {}
variable "private_image_repo_version" {}
variable "private_registry_docker_username" {}
variable "private_registry_docker_password" {}
variable "private_installer" {}
variable "icp_install_dbg" {}
variable "icp_docker_tar" {}
variable "icp_docker_tar_boot_path" {}
variable "icp_docker_tar_master_path" {}
variable "icp_docker_tar_mgmt_path" {}
variable "icp_docker_tar_proxy_path" {}
variable "icp_docker_tar_worker_path" {}
