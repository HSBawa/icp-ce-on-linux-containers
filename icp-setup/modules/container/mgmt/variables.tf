###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
## Profile Output
variable "icp_ce_profile_name"{}
variable "icp_ce_mgmt_profile_name"{type = "list"}

## Map Keys
variable "ephemeral"{default="ephemeral"}
variable "name"{default="name"}
variable "node_count"{default="node_count"}
variable "name_short"{default="name_short"}
variable "remote"{default="remote"}
variable "image"{default="image"}

## Configuration (MAP)
variable "environment"{type = "map"}
variable "management_node" {type = "map"}
variable "cluster"{type = "map"}
variable "icp"{type = "map"}
variable "lxd"{type = "map"}
