mkdir -p /media/nfs 
  * Create folders /media/nfs/vol1 ... /media/nfs/vol10
  
lxc profile create nfs-server

cat nfs-server-profile.yaml | lxc profile edit nfs-server

lxc launch ubuntu:16.04 nfs-server --config security.privileged=true -p nfs-server -p default -c raw.apparmor="mount fstype=rpc_pipefs, mount fstype=nfsd,"

lxc exec nfs-server bash
  * apt install nfs-kernel-server nfs-common -y 

