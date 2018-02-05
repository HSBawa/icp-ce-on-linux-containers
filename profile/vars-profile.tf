variable "net_device_parent" {type = "list"}
variable "ipv4_address_cidr_profile"{type="list"}
variable "env_prefix"{}
variable "boot_cpu" {default = "2"}
variable "master_cpu" {default = "2"}
variable "mgmt_cpu" {default = "2"}
variable "proxy_cpu" {default = "2"}
variable "worker_1_cpu" {default = "2"}
variable "worker_2_cpu" {default = "2"}
variable "worker_3_cpu" {default = "2"}
variable "net_device_name" {}
variable "net_device_type" {default = "nic"}
variable "net_device_nic_type" {default = "bridged"}
variable "icp_ce_profile_name"{default="common"}
variable "icp_ce_boot_profile_name"{default="boot"}
variable "icp_ce_master_profile_name"{default="master"}
variable "icp_ce_mgmt_profile_name"{default="mgmt"}
variable "icp_ce_proxy_profile_name"{default="proxy"}
variable "icp_ce_worker_1_profile_name"{default="worker-1"}
variable "icp_ce_worker_2_profile_name"{default="worker-2"}
variable "icp_ce_worker_3_profile_name"{default="worker-3"}
variable "boot_host_num"{}
variable "master_host_num"{}
variable "proxy_host_num"{}
variable "mgmt_host_num"{}
variable "worker_1_host_num"{}
variable "worker_2_host_num"{}
variable "worker_3_host_num"{}
