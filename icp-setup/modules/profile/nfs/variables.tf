###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################

## Define keys for maps
variable "name_short"{default="name_short"}
variable "shared_device_path"{default="shared_device_path"}
variable "nfs_device_path"{default="nfs_device_path"}
variable "shared_device_source"{default="shared_device_source"}
variable "nfs_device_source"{default="nfs_device_source"}
variable "name"{default="name"}
variable "remote"{default="remote"}
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
variable "ipv4_cidr_count"{}


variable "environment"{type = "map"}
variable "nfs_node"{type = "map"}
variable "lxd"{type = "map"}
variable "lxd_network"{type = "map"}
