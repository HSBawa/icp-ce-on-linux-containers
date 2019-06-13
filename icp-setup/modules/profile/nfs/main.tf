###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
resource "lxd_profile" "nfs" {
  name      = "${var.environment[var.name_short]}-${var.nfs_node[var.name]}"
  description = "ICP CE NFS Profile : ${var.environment[var.name_short]}-${var.nfs_node[var.name]}"
  remote = "${var.lxd[var.remote]}"

  config {
     boot.autostart ="true"
     linux.kernel_modules = "bridge,br_netfilter,x_tables,ip_tables,ip_vs,ip_set,ipip,xt_mark,xt_multiport,ip_tunnel,tunnel4,netlink_diag,nf_conntrack,nfnetlink,overlay"
     raw.lxc= "lxc.apparmor.profile = unconfined\nlxc.cgroup.devices.allow = a\nlxc.mount.auto=proc:rw sys:rw cgroup:rw\nlxc.cap.drop ="
     ## New spec was causing issue. Switching to older specs
     #raw.lxc= "lxc.aa_profile = unconfined\nlxc.cgroup.devices.allow = a\nlxc.mount.auto=proc:rw sys:rw cgroup:rw\nlxc.cap.drop ="
     security.nesting = "true"
     security.privileged = "true"
     raw.apparmor="mount fstype=rpc_pipefs, mount fstype=nfsd,"
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
       # ipv4.address="${cidrhost(element(split(",",var.lxd_network[var.ipv4_cidr]), count.index % var.ipv4_cidr_count), var.nfs_node[var.start_host_num] + (count.index % var.ipv4_cidr_count))}"
       ipv4.address="${cidrhost(element(split(",",var.lxd_network[var.ipv4_cidr]), count.index % var.ipv4_cidr_count), var.nfs_node[var.start_host_num] + count.index)}"
     }
   }

   #### Root device
   device {
     name = "${var.nfs_node[var.storage_device_name]}"
     type = "${var.nfs_node[var.storage_device_type]}"
     properties {
       path="${var.nfs_node[var.storage_device_path]}"
       pool="${var.nfs_node[var.storage_device_pool]}"
       size="${var.nfs_node[var.storage_device_size]}"
     }
   }


   ## Make sure to create folder /media/lxcshare (or folder of your choice)
   ## to allow mount on container. Modify source value accordingly
   device {
     name = "shared_folder"
     type = "disk"
     properties {
       ## Host folder
       source = "${var.nfs_node[var.shared_device_source]}"
       ## Container folder
       path   = "${var.nfs_node[var.shared_device_path]}"
     }
   }

   device {
     name = "nfs_folder"
     type = "disk"
     properties {
       ## Host folder
       source = "${var.nfs_node[var.nfs_device_source]}"
       ## Container folder
       path   = "${var.nfs_node[var.nfs_device_path]}"
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
output "nfs_profile_name_output" {
  value = "${lxd_profile.nfs.*.name}"
}
