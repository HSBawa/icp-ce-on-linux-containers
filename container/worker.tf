###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_worker_1" {
  name      = "${var.env_prefix}-${var.icp_ce_worker_1_container_name}"
  remote    = "${var.remote_name}"
  image     = "${var.image_name}"
  ephemeral = "${var.is_ephemeral}"
  profiles  = ["${var.default_profile_name}", "${var.icp_ce_profile_name}", "${var.icp_ce_worker_1_profile_name}"]
}

resource "lxd_container" "icp_ce_worker_2" {
  name      = "${var.env_prefix}-${var.icp_ce_worker_2_container_name}"
  remote    = "${var.remote_name}"
  image     = "${var.image_name}"
  ephemeral = "${var.is_ephemeral}"
  profiles  = ["${var.default_profile_name}", "${var.icp_ce_profile_name}", "${var.icp_ce_worker_2_profile_name}"]
}

resource "lxd_container" "icp_ce_worker_3" {
  name      = "${var.env_prefix}-${var.icp_ce_worker_3_container_name}"
  remote    = "${var.remote_name}"
  image     = "${var.image_name}"
  ephemeral = "${var.is_ephemeral}"
  profiles  = ["${var.default_profile_name}", "${var.icp_ce_profile_name}", "${var.icp_ce_worker_3_profile_name}"]
}
