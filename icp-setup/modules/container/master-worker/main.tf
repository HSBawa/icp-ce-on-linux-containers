###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_master" {
    count = "${var.master_node[var.node_count]}"
    name      = "${var.environment[var.name_short]}-${var.master_node[var.name]}-${count.index}"
    remote    = "${var.lxd[var.remote]}"
    image     = "${var.lxd[var.image]}"
    ephemeral = "${var.lxd[var.ephemeral]}"
    profiles  = ["${var.icp_ce_profile_name}", "${var.icp_ce_master_profile_name[count.index]}"]
    #depends_on = ["lxd_container.icp_ce_proxy", "lxd_container.icp_ce_mgmt", "lxd_container.icp_ce_worker"]
    depends_on = ["lxd_container.icp_ce_worker"]
    #depends_on = @@MASTER_DEPENDS_ON@@

    #############################################################################
    ### Start ICP Setup/Install Process
    #############################################################################

    provisioner "local-exec" {
         command = "echo Cluster is now ready to use. ; echo Starting ICP Configuration and Installation Process.;chmod +x ./icp-setup/scripts/*.sh ; ./icp-setup/scripts/install-icp.sh"
    }
}

###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_container" "icp_ce_worker" {
    count = "${var.worker_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.worker_node[var.name]}-${count.index}"
    remote    = "${var.lxd[var.remote]}"
    image     = "${var.lxd[var.image]}"
    ephemeral = "${var.lxd[var.ephemeral]}"
    profiles  = ["${var.icp_ce_profile_name}", "${var.icp_ce_worker_profile_name[count.index]}"]
}
