###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_mgmt" {
    count="${var.management_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.management_node[var.name]}-${count.index}"
    remote    = "${var.lxd[var.remote]}"
    image     = "${var.lxd[var.image]}"
    ephemeral = "${var.lxd[var.ephemeral]}"
    profiles  = ["${var.icp_ce_profile_name}", "${var.icp_ce_mgmt_profile_name[count.index]}"]
}

