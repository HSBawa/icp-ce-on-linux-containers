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
