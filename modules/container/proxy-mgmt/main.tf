###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_mgmt" {
    count="${var.management_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.management_node[var.name]}-${count.index}"
    remote    = "${lookup(var.lxd_image, var.remote)}"
    image     = "${lookup(var.lxd_image, var.name)}"
    ephemeral = "${lookup(var.lxd_image, var.ephemeral)}"
    profiles  = ["${var.icp_ce_profile_name}", "${var.icp_ce_mgmt_profile_name[count.index]}"]
}

###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_proxy" {
    count = "${var.proxy_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.proxy_node[var.name]}-${count.index}"
    remote    = "${lookup(var.lxd_image, var.remote)}"
    image     = "${lookup(var.lxd_image, var.name)}"
    ephemeral = "${lookup(var.lxd_image, var.ephemeral)}"
    profiles  = ["${var.icp_ce_profile_name}", "${var.icp_ce_proxy_profile_name[count.index]}"]
}
