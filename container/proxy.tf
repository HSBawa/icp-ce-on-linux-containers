###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_proxy" {
  name      = "${var.env_prefix}-${var.icp_ce_proxy_container_name}"
  remote    = "${var.remote_name}"
  image     = "${var.image_name}"
  ephemeral = "${var.is_ephemeral}"
  profiles  = ["${var.default_profile_name}", "${var.icp_ce_profile_name}", "${var.icp_ce_proxy_profile_name}"]
}
