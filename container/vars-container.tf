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
variable "install_kibana" {}
variable "icp_version" {}
variable "icp_edition" {}
variable "icp_installer" {}
variable "icp_install_dbg" {}
variable "private_registry_enabled" {}
variable "private_registry_server" {}
variable "private_image_repo" {}
variable "private_image_repo_version" {}
variable "private_registry_docker_username" {}
variable "private_registry_docker_password" {}
variable "private_installer" {}
variable "icp_docker_tar" {}
variable "icp_docker_tar_boot_path" {}
variable "icp_docker_tar_master_path" {}
variable "icp_docker_tar_mgmt_path" {}
variable "icp_docker_tar_proxy_path" {}
variable "icp_docker_tar_worker_path" {}
