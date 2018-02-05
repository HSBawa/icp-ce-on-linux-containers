###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_boot" {
  name      = "${var.env_prefix}-${var.icp_ce_boot_container_name}"
  remote    = "${var.remote_name}"
  image     = "${var.image_name}"
  ephemeral = "${var.is_ephemeral}"
  profiles  = ["${var.default_profile_name}", "${var.icp_ce_profile_name}", "${var.icp_ce_boot_profile_name}"]
  depends_on = ["lxd_container.icp_ce_master"]

  ##  REVIEW FILE "./utils/init_boot.sh" AND TUNE TO YOUR NEEDS
  # provisioner "local-exec" {
  #      command = "chmod +x ./utils/init_boot.sh; ./utils/init_boot.sh ${var.env_prefix}-${var.icp_ce_boot_container_name}  ${var.env_prefix}-${var.icp_ce_master_container_name} ${var.env_prefix}-${var.icp_ce_mgmt_container_name} ${var.env_prefix}-${var.icp_ce_proxy_container_name} ${var.env_prefix}-${var.icp_ce_worker_1_container_name} ${var.env_prefix}-${var.icp_ce_worker_2_container_name} ${var.env_prefix}-${var.icp_ce_worker_3_container_name} ${var.env_prefix} ${var.admin_pass} ${var.disabled_management_services}"
  # }
  provisioner "local-exec" {
       command = "chmod +x ./utils/init_boot.sh; ./utils/init_boot.sh ${var.env_prefix}-${var.icp_ce_boot_container_name}  ${var.env_prefix}-${var.icp_ce_master_container_name} ${var.env_prefix}-${var.icp_ce_mgmt_container_name} ${var.env_prefix}-${var.icp_ce_proxy_container_name} ${var.env_prefix}-${var.icp_ce_worker_1_container_name} ${var.env_prefix}-${var.icp_ce_worker_2_container_name} ${var.env_prefix}-${var.icp_ce_worker_3_container_name} ${var.env_prefix} ${var.admin_pass} ${var.disabled_management_services} ${var.cluster_name} ${var.cluster_domain} \"${var.cluster_CA_domain}\""
  }

}
