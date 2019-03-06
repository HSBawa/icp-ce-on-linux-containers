###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_profile" "icp_ce_mgmt" {
    count = "${var.management_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.management_node[var.name]}-${count.index}"
    description = "LXD Profile for ${var.environment[var.name_short]}-${var.management_node[var.name]}-${count.index}"
    remote    = "${var.lxd[var.remote]}"

    config {
       #limits.cpu = "${var.management_node[var.cpu]}"
       #user.user-data = "${file("./user-data/cloud-config-icp.yaml")}"
     }

     #############################################################################
     #   eth0:
     #     name: eth0
     #     nictype: bridged
     #     parent: lxdbr0
     #     type: nic
     #############################################################################
     device {
       name = "${var.lxd_network[var.device_name]}"
       type = "${var.lxd_network[var.device_type]}"

       properties {
         parent="${var.net_device_parent[(count.index % var.ipv4_cidr_count)]}"
         nictype="${var.lxd_network[var.nic_type]}"
         ## TODO: This need to be fixed and tested
         # ipv4.address="${cidrhost(element(split(",",var.lxd_network[var.ipv4_cidr]), count.index % var.ipv4_cidr_count), var.management_node[var.start_host_num] + (count.index % var.ipv4_cidr_count))}"
         ipv4.address="${cidrhost(element(split(",",var.lxd_network[var.ipv4_cidr]), count.index % var.ipv4_cidr_count), var.management_node[var.start_host_num] + count.index)}"
       }
     }

     #### Root device
     device {
       name = "${var.management_node[var.storage_device_name]}"
       type = "${var.management_node[var.storage_device_type]}"
       properties {
         path="${var.management_node[var.storage_device_path]}"
         pool="${var.management_node[var.storage_device_pool]}"
         size="${var.management_node[var.storage_device_size]}"
       }
     }
}

### Define the output to use in root main.tf
output "icp_ce_mgmt_profile_name_output" {
  value = "${lxd_profile.icp_ce_mgmt.*.name}"
}
