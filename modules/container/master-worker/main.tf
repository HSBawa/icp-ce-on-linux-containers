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

    provisioner "local-exec" {
         command = "echo Cluster is now ready to use. ; echo Starting ICP Configuration and Installation Process; echo Cluster type is - 0 for Full and 1 for minimal : ${var.cluster[var.minimal]}"
    }


  #   ############################################################################
  #   ## Start ICP Setup and Install Process
  #   ## TODO: Add set of variables that are needed in install-icp.sh file on top
  #   ############################################################################
    provisioner "local-exec" {
         command = "chmod +x ./scripts/*.sh ; ./scripts/install-icp.sh ${var.environment[var.name_short]} ${var.cluster[var.minimal]} ${var.icp[var.version]} ${var.icp[var.edition]} ${var.icp[var.installer]} ${var.icp[var.install_dbg]} ${var.icp[var.recommended_root_size]} ${var.cluster[var.admin_user]} ${var.cluster[var.admin_pass]} ${var.cluster[var.cluster_name]} ${var.cluster[var.cluster_domain]}  \"${var.cluster[var.cluster_CA_domain]}\" ${var.cluster[var.default_namespace]} ${var.master_node[var.name]} ${var.cluster[var.cluster_lb_address]}  ${var.cluster[var.proxy_lb_address]},  \"${var.cluster[var.disabled_management_services]}\""
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
