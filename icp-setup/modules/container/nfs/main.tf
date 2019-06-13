
###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "nfs" {
    count = "${var.nfs_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.nfs_node[var.name]}-${count.index}"
    remote    = "${var.lxd[var.remote]}"
    image     = "${var.lxd[var.nfs_image]}"
    ephemeral = "${var.lxd[var.ephemeral]}"
    profiles  = ["${var.nfs_profile_name[count.index]}"]
}
