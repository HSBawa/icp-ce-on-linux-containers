###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_master" {
  name      = "${var.env_prefix}-${var.icp_ce_master_container_name}"
  remote    = "${var.remote_name}"
  image     = "${var.image_name}"
  ephemeral = "${var.is_ephemeral}"
  depends_on = ["lxd_container.icp_ce_proxy", "lxd_container.icp_ce_proxy", "lxd_container.icp_ce_mgmt", "lxd_container.icp_ce_worker_1", "lxd_container.icp_ce_worker_2", "lxd_container.icp_ce_worker_3"]
  profiles  = ["${var.default_profile_name}", "${var.icp_ce_profile_name}", "${var.icp_ce_master_profile_name}"]
}
