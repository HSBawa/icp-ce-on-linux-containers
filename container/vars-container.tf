###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
variable "env_prefix"{}
variable "admin_pass"{}
variable "image_name"{}
variable "icp_ce_profile_name"{}
variable "icp_ce_boot_profile_name"{}
variable "icp_ce_master_profile_name"{}
variable "icp_ce_mgmt_profile_name"{}
variable "icp_ce_proxy_profile_name"{}
variable "icp_ce_worker_1_profile_name"{}
variable "icp_ce_worker_2_profile_name"{}
variable "icp_ce_worker_3_profile_name"{}
variable "default_profile_name"{default = "default"}
variable "remote_name"{default="local"}
variable "is_ephemeral"{default=false}
variable "is_privileged"{default=true}
variable "icp_ce_boot_container_name"{default ="boot"}
variable "icp_ce_master_container_name"{default ="master"}
variable "icp_ce_mgmt_container_name"{default ="mgmt"}
variable "icp_ce_proxy_container_name"{default ="proxy"}
variable "icp_ce_worker_1_container_name"{default ="worker-1"}
variable "icp_ce_worker_2_container_name"{default ="worker-2"}
variable "icp_ce_worker_3_container_name"{default ="worker-3"}
variable "disabled_management_services" {default="[]"}
variable "cluster_name" {}
variable "cluster_domain" {}
variable "cluster_CA_domain" {}
