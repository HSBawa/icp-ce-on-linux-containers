###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_profile" "icp_ce_master" {
    count = "${var.master_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.master_node[var.name]}-${count.index}"
    description = "LXD Profile for ${var.environment[var.name_short]}-${var.master_node[var.name]}-${count.index}"

    config {
       #limits.cpu = "${var.master_node[var.cpu]}"
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
         #ipv4.address="${cidrhost(element(split(",",var.lxd_network[var.ipv4_cidr]), count.index % var.ipv4_cidr_count), var.master_node[var.start_host_num] + (count.index % var.ipv4_cidr_count))}"
         ipv4.address="${cidrhost(element(split(",",var.lxd_network[var.ipv4_cidr]), count.index % var.ipv4_cidr_count), var.master_node[var.start_host_num] + count.index)}"
       }
     }

     #### Root device
     device {
       name = "${var.master_node[var.storage_device_name]}"
       type = "${var.master_node[var.storage_device_type]}"
       properties {
         path="${var.master_node[var.storage_device_path]}"
         pool="${var.master_node[var.storage_device_pool]}"
         size="${var.master_node[var.storage_device_size]}"
       }
     }
}

### Define the output to use in root main.tf
output "icp_ce_master_profile_name_output" {
  value = "${lxd_profile.icp_ce_master.*.name}"
}

###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_profile" "icp_ce_worker" {
    count = "${var.worker_node[var.node_count]}"
    name  = "${var.environment[var.name_short]}-${var.worker_node[var.name]}-${count.index}"
    description = "LXD Profile for ${var.environment[var.name_short]}-${var.worker_node[var.name]}-${count.index}"

    config {
       #limits.cpu = "${var.worker_node[var.cpu]}"
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
         # ipv4.address="${cidrhost(element(split(",",var.lxd_network[var.ipv4_cidr]), count.index % var.ipv4_cidr_count), var.worker_node[var.start_host_num] + (count.index % var.ipv4_cidr_count))}"
         ipv4.address="${cidrhost(element(split(",",var.lxd_network[var.ipv4_cidr]), count.index % var.ipv4_cidr_count), var.worker_node[var.start_host_num] + count.index)}"

       }
     }

     #### Root device
     device {
       name = "${var.worker_node[var.storage_device_name]}"
       type = "${var.worker_node[var.storage_device_type]}"
       properties {
         path="${var.worker_node[var.storage_device_path]}"
         pool="${var.worker_node[var.storage_device_pool]}"
         size="${var.worker_node[var.storage_device_size]}"
       }
     }
}

### Define the output to use in root main.tf
output "icp_ce_worker_profile_name_output" {
  value = "${lxd_profile.icp_ce_worker.*.name}"
}


###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_profile" "icp_ce" {
  name      = "${var.environment[var.name_short]}-${var.common_profile[var.name]}"
  description = "ICP CE Base Profile : ${var.environment[var.name_short]}-${var.common_profile[var.name]}"

  config {
     boot.autostart ="true"
     linux.kernel_modules = "bridge,br_netfilter,x_tables,ip_tables,ip_vs,ip_set,ipip,xt_mark,xt_multiport,ip_tunnel,tunnel4,netlink_diag,nf_conntrack,nfnetlink,overlay"
     raw.lxc= "lxc.apparmor.profile = unconfined\nlxc.cgroup.devices.allow = a\nlxc.mount.auto=proc:rw sys:rw cgroup:rw\nlxc.cap.drop ="
     ## New spec was causing issue. Switching to older specs
     #raw.lxc= "lxc.aa_profile = unconfined\nlxc.cgroup.devices.allow = a\nlxc.mount.auto=proc:rw sys:rw cgroup:rw\nlxc.cap.drop ="
     security.nesting = "true"
     security.privileged = "true"
   }

   ## Make sure to create folder /media/lxcshare (or folder of your choice)
   ## to allow mount on container. Modify source value accordingly
   device {
     name = "shared_folder"
     type = "disk"
     properties {
       ## Host folder
       source = "/media/lxcshare"
       ## Container folder
       path   = "/share"
     }
   }

   device {
     name = "aadisable"
     type = "disk"
     properties {
       source = "/dev/null"
       path   = "/sys/module/apparmor/parameters/enabled"
     }
   }

   device {
     name = "aadisable1"
     type = "disk"
     properties {
       source = "/dev/null"
       path   = "/sys/module/nf_conntrack/parameters/hashsize"
     }
   }
}

### Define the output to use in root main.tf
output "icp_ce_profile_name_output" {
  value = "${lxd_profile.icp_ce.name}"
}
