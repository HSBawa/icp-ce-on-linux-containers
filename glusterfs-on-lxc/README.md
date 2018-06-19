You can use this script to setup a 2 Node GlusterFS Server on LXC Containers to use with IBM Cloud Private or any other Kubernetes setup for GlusterFS storage.
This sever will create 10 volumes.

Pre-Requisites: 
  * Internet access (to download base Ubuntu LXD image, if not available locally)
  * LXD 2.21
  * Ubuntu 16.04 LTS or Ubuntu 17.10 (Artful) host. 
  * [Packer](https://www.packer.io/downloads.html) to build image for GlusterFS Server
  * Following shared folders on your host machine:
    * /media/glusterfs/server1
    * /media/glusterfs/server2
    * /media/lxcshare

Create LXD Image for GlusterFS Server: 
  * cd to '<path to icp-ce-on-linux-containers>/gluster-for-lxc' folder
  * packer validate xenial-packer-lxd-image-for-gfs
  * packer build xenial-packer-lxd-image-for-gfs
    * This is one time step and repeat only if "xenial-container-for-glusterfs-server" image is removed/deleted from local repository.
      * lxc image list xenial-container-for-glusterfs-server   
  
Build: 
  * cd to '<path to icp-ce-on-linux-containers>/gluster-for-lxc' folder
  * chmod +x glusterfs-server-lxc.sh
  * ./glusterfs-server-lxc.sh

Enjoy!!!

  
