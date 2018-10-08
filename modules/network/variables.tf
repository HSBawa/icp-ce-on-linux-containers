###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################

###KEYS
variable "ipv4_cidr"{default="ipv4_cidr"}
variable "ipv6_cidr"{default="ipv6_cidr"}
variable "ipv4_nat"{default="ipv4_nat"}
variable "ipv6_nat"{default="ipv6_nat"}
variable "name"{default="name"}
variable "name_short"{default="name_short"}
variable "net_count"{default="net_count"}
variable "remote"{default="remote"}
###MAPS
variable "environment"{type = "map"}
variable "lxd_network"{type = "map"}
variable "lxd"{type = "map"}
