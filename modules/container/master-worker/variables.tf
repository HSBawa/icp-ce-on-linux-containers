###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
## Profile Output
variable "icp_ce_profile_name"{}
variable "icp_ce_master_profile_name"{type = "list"}
variable "icp_ce_worker_profile_name"{type = "list"}

## Map Keys
variable "ephemeral"{default="ephemeral"}
variable "remote"{default="remote"}
variable "name"{default="name"}
variable "node_count"{default="node_count"}
variable "name_short"{default="name_short"}
variable "version"{default="tag"}
variable "edition"{default="edition"}
variable "installer"{default="installer"}
variable "install_dbg"{default="install_dbg"}
variable "recommended_root_size"{default="min_avail_root_size"}
variable "minimal"{default="minimal"}
variable "admin_user"{default="admin_user"}
variable "admin_pass"{default="admin_pass"}
variable "cluster_name"{default="name"}
variable "cluster_domain"{default="domain"}
variable "cluster_CA_domain"{default="CA_domain"}
variable "default_namespace"{default="default_namespace"}
variable "cluster_lb_address"{default="cluster_lb_address"}
variable "proxy_lb_address"{default="proxy_lb_address"}
variable "disabled_management_services"{default="disabled_management_services"}

## Configuration (MAP)
variable "environment"{type = "map"}
variable "cluster"{type = "map"}
variable "icp"{type = "map"}
variable "lxd_image"{type = "map"}
variable "master_node" {type = "map"}
variable "worker_node" {type = "map"}
variable "icp_docker_image_archives" {type = "map"}
variable "common_profile"{type = "map"}
