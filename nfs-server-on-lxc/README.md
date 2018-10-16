**Steps to setup NFS Server**

* Create directories on your host to hold data:
  * `mkdir -p /media/nfs`
  * Create folders /media/nfs/vol1 ... /media/nfs/vol10
  
* Create LXD profile
  * `lxc profile create nfs-server`
  * `cat nfs-server-profile.yaml | lxc profile edit nfs-server`

* Create LXD container
  * `lxc launch ubuntu:xenial/amd64 nfs-server -p nfs-server -p default -c security.privileged=true -c raw.apparmor="mount fstype=rpc_pipefs, mount fstype=nfsd,"`

* Install NFS server/client and configure exports file on _nfs-server_ container. 
  * `lxc exec nfs-server bash`
    * `apt install nfs-kernel-server nfs-common -y`
    * `vi /etc/exports`
 
          /nfs/vol1   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol2   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol3   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol4   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol5   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol6   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol7   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol8   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol9   *(rw,sync,no_root_squash,no_subtree_check,insecure)
          /nfs/vol10  *(rw,sync,no_root_squash,no_subtree_check,insecure)
          
     * exportfs -a


* Grab IP address of nfs-server container to use with NFS based PVs
  * `lxc list nfs-server -c 4 --format=csv | awk '{print $1}'`


