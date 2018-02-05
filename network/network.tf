###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_network" "icp_ce_network" {
  count = "${length (var.ipv4_address_cidr)}"
  name  = "${var.env_prefix}${var.network_name[count.index]}"
  config {
    ## ipv4 cidr
    ipv4.address = "${var.ipv4_address_cidr[count.index]}"
    ipv4.nat     = "${ var.ipv4_nat }"
    ## ipv6 cidr
    ipv6.address = "${var.ipv6_address_cidr[count.index]}"
    ipv6.nat     = "${ var.ipv6_nat }"
  }
}

output "icp_ce_network_name_output" {
  value = "${lxd_network.icp_ce_network.*.name}"
}

output "ipv4_address_cidr" {
  value = "${var.ipv4_address_cidr}"
}

output "icp_ce_network_env_prefix_output" {
  value = "${var.env_prefix}"
}
