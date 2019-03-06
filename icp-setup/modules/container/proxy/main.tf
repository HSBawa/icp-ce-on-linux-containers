
###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_proxy" {
    count = "${var.proxy_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.proxy_node[var.name]}-${count.index}"
    remote    = "${var.lxd[var.remote]}"
    image     = "${var.lxd[var.image]}"
    ephemeral = "${var.lxd[var.ephemeral]}"
    profiles  = ["${var.icp_ce_profile_name}", "${var.icp_ce_proxy_profile_name[count.index]}"]
}
