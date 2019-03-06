###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
###KEYS
variable "net_device_parent" {type = "list"}
variable "nic_type"{default="nic_type"}
variable "device_name"{default="device_name"}
variable "device_type"{default="device_type"}
variable "ipv4_cidr"{default="ipv4_cidr"}
variable "start_host_num"{default="start_host_num"}
variable "storage_device_name"{default="storage_device_name"}
variable "storage_device_type"{default="storage_device_type"}
variable "storage_device_path"{default="storage_device_path"}
variable "storage_device_pool"{default="storage_device_pool"}
variable "storage_device_size"{default="storage_device_size"}
variable "name"{default="name"}
variable "node_count"{default="node_count"}
variable "cpu"{default="cpu"}
variable "name_short"{default="name_short"}
variable "ipv4_cidr_count"{}
variable "remote"{default="remote"}

variable "environment"{type = "map"}
variable "icp"{type = "map"}
variable "lxd_network"{type = "map"}
variable "master_node" {type = "map"}
variable "worker_node" {type = "map"}
variable "common_profile"{type = "map"}
variable "lxd"{type = "map"}
