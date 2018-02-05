###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################

provider "lxd"{
   generate_client_certificates = true
   accept_remote_certificate    = true

   ### Get info using command:  lxc remote list
   ### Local (usually default)
   ### Local declarion is not required
   ### LXD provider will fallback to local if no remotes defined
   lxd_remote {
     name     = "local"
     scheme   = "unix"
     address  = ""
     password = ""
   }

   # ### Images
   #  lxd_remote {
   #    name     = "images"
   #    scheme   = "https"
   #    address  = "images.linuxcontainers.org"
   #    password = ""
   #  }
  #
  # ### Ubuntu Remote (Releases)
  #  lxd_remote {
  #    name     = "ubuntu"
  #    scheme   = "https"
  #    address  = "cloud-images.ubuntu.com/releases"
  #    password = ""
  #  }
  #
  #  ### Ubuntu Remote (Daily)
  #   lxd_remote {
  #     name     = "ubuntu-daily"
  #     scheme   = "https"
  #     address  = "cloud-images.ubuntu.com/daily"
  #     password = ""
  #   }
}


module "network" {
  source = "./network"
  ipv4_address_cidr = "${var.ipv4_cidr}"
  ipv6_address_cidr = "${var.ipv6_cidr}"
  network_name = "${var.network_name}"
  env_prefix = "${var.env_prefix}"
  ipv4_nat="${var.ipv4_nat}"
  ipv6_nat="${var.ipv6_nat}"
}

module "profile" {
  source = "./profile"
  net_device_parent="${module.network.icp_ce_network_name_output}"
  net_device_nic_type="${var.net_device_nic_type}"
  net_device_name="${var.net_device_name}"
  net_device_type="${var.net_device_type}"
  ipv4_address_cidr_profile= "${var.ipv4_cidr}"
  env_prefix = "${var.env_prefix}"
  boot_host_num="${var.boot_host_num}"
  master_host_num="${var.master_host_num}"
  proxy_host_num="${var.proxy_host_num}"
  mgmt_host_num="${var.mgmt_host_num}"
  worker_1_host_num="${var.worker_1_host_num}"
  worker_2_host_num="${var.worker_2_host_num}"
  worker_3_host_num="${var.worker_3_host_num}"

}

module "container" {
  source = "./container"
  icp_ce_profile_name= "${module.profile.icp_ce_profile_name_output}"
  icp_ce_boot_profile_name= "${module.profile.icp_ce_boot_profile_name_output}"
  icp_ce_master_profile_name= "${module.profile.icp_ce_master_profile_name_output}"
  icp_ce_mgmt_profile_name= "${module.profile.icp_ce_mgmt_profile_name_output}"
  icp_ce_proxy_profile_name= "${module.profile.icp_ce_proxy_profile_name_output}"
  icp_ce_worker_1_profile_name= "${module.profile.icp_ce_worker_1_profile_name_output}"
  icp_ce_worker_2_profile_name= "${module.profile.icp_ce_worker_2_profile_name_output}"
  icp_ce_worker_3_profile_name= "${module.profile.icp_ce_worker_3_profile_name_output}"
  env_prefix = "${var.env_prefix}"
  image_name="${var.lxd_image_name}"
  remote_name="${var.remote_name}"
  admin_pass="${var.admin_pass}"
  disabled_management_services="${var.disabled_management_services}"
  cluster_name="${var.cluster_name}"
  cluster_domain="${var.cluster_domain}"
  cluster_CA_domain="${var.cluster_CA_domain}"
}
