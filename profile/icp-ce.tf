resource "lxd_profile" "icp_ce" {
  name      = "${var.env_prefix}-${var.icp_ce_profile_name}"
  description = "ICP CE Base Profile"

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
