###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
## Profile Output
variable "nfs_profile_name"{type = "list"}

## Map Keys
variable "ephemeral"{default="ephemeral"}
variable "remote"{default="remote"}
variable "name"{default="name"}
variable "node_count"{default="node_count"}
variable "name_short"{default="name_short"}
variable "image"{default="image"}

## Configuration (MAP)
variable "environment"{type = "map"}
variable "nfs_node" {type = "map"}
variable "lxd"{type = "map"}
