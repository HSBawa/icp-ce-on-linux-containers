###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_network" "icp_ce_network" {
  count = "${length(split(",",var.lxd_network[var.ipv4_cidr]))}"
  #count = "${length(list(var.lxd_network[var.ipv4_cidr]))}"
  name  = "${var.environment[var.name_short]}${element(list(var.lxd_network[var.name]),count.index)}${count.index}"
  config {
    ## ipv4 cidr
    ipv4.address = "${element(split(",",var.lxd_network[var.ipv4_cidr]), count.index)}"
    ipv4.nat     = "${var.lxd_network[var.ipv4_nat]}"
    ## ipv6 cidr
    ipv6.address = "${element(split(",",var.lxd_network[var.ipv6_cidr]),count.index)}"
    ipv6.nat     = "${var.lxd_network[var.ipv6_nat]}"
  }
}

output "icp_ce_network_name_output" {
  value = "${lxd_network.icp_ce_network.*.name}"
}

output "ipv4_cidr_count_output" {
  value = "${ length( split(",",var.lxd_network[var.ipv4_cidr]) ) }"
}

output "icp_ce_network_env_prefix_output" {
  value = "${var.environment[var.name_short]}"
}
