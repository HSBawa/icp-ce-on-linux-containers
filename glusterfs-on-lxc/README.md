You can use this script to setup a 2 Node GlusterFS Server on LXC Containers to use with IBM Cloud Private or any other Kubernetes setup for GlusterFS storage.
This sever will create 10 volumes.

Pre-Requisites: 
  * Internet access (to download base Ubuntu LXD image, if not available locally)
  * LXD 2.21 or above
  * Ubuntu 16.04 LTS or 18.04 LTS host. 
  * [Packer](https://www.packer.io/downloads.html) to build image for GlusterFS Server
  * Following shared folders on your host machine:
    * /media/glusterfs/server1  (`mkdir -p /media/glusterfs/server1`)
    * /media/glusterfs/server2  (`mkdir -p /media/glusterfs/server2`)
    * /media/lxcshare           (`mkdir -p /media/lxcshare`)
  * This script uses 'default' lxd profile. If you plan to use different profile, update 'profiles' property in [glusterfs-server-lxc.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/glusterfs-on-lxc/glusterfs-server-lxc.sh) accordingly. 
  * Update 'node_ip_pre' property with the network CIDR used by Profile. Perform following steps to retrieve CIDR info
    * Run: `lxd profile show &lt;profile name&gt;`  (in this case &lt;profile name&gt; is 'default')
      * Look for _parent_ value: 
      
             devices:
               eth0:
                 name: eth0
                 nictype: bridged
                 parent: lxdbr0
                 type: nic'         
    * Run: `lxd network show &lt;network name&gt;`  (in this case &lt;network name&gt; is 'lxdbr0')
      * Look for _ipv4.address_ value
      
             config:
             ipv4.address: 10.30.30.1/24
             ipv4.nat: "true"
             ipv6.address: none
       * Use '10.30.30.' as node_ip_pre value
      
Create LXD Image for GlusterFS Server: 
  * cd to 'icp-ce-on-linux-containers/gluster-for-lxc' folder
  * Run: `packer validate xenial-packer-lxd-image-for-gfs`
  * Run: `packer build xenial-packer-lxd-image-for-gfs`
    * This is one time step and repeat only if "xenial-container-for-glusterfs-server" image is removed/deleted from local repository.
      * Run: `lxc image list xenial-container-for-glusterfs-server`
  
Build: 
  * Change directory to 'icp-ce-on-linux-containers/gluster-for-lxc' folder
  * Run: `chmod +x glusterfs-server-lxc.sh`
  * Run: `./glusterfs-server-lxc.sh`

Update /etc/hosts file:
  * Assuming that 'node_name_pre' and node_start_index values are unchanged:
    * Add following to the /etc/hosts file of host server:
    
          ##Gluster FS Server
          <IP-ADDRESS-1> glusterfs-server-1
          <IP-ADDRESS-2> glusterfs-server-2


Test GlusterFS :
  * Make sure GlusterFS client package is installed usign command `apt list glusterfs-client`. if not installed, follow instructions below:
         
        apt-get update
        add-apt-repository -y -u ppa:gluster/glusterfs-3.13
        apt-get update
        apt install -y glusterfs-client  
        
  * Run: `mkdir /mnt/glusterfs/vol1`
  * Run: `mount -t glusterfs glusterfs-server-1:/vol1 /mnt/glusterfs/vol1`
    * If returns error, debugging may be requird. 
  * Run: `echo "Hello World" > /mnt/glusterfs/vol1/hello.txt`
  * Run: `lxc exec glusterfs-server-1 -- sh -c "ls -al /volume/data1"`
    * Must list hello.txt file.
  * Run: `lxc exec glusterfs-server-1 -- sh -c "cat /volume/data1/hello.txt"`
  * Run: `umount /mnt/glusterfs/vol1`
  
  
  Enjoy!!!

  
