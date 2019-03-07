Welcome to my IBM Cloud Private (Community Edition) on Linux Containers Infrastructure as a Code (IaaC). With the help of this IaaC, developers can easily setup a **multi virtual node ICP cluster** on a **single** Linux Metal/VM!!!<br>

This IaC not only takes away the pain of all manual configuration, but will also save valuable resources (nodes) by utilizing a single host machine to provide multi node ICP Kubernetes experience. It will install required CLIs, setup LXD, setup ICP-CE and some utility scripts.

As ICP is installed on LXD VMs, it can be easily installed and removed without any impact to host environment. Only LXD, CLIs and other desired/required packages will be installed on the host.

[High Level Architecture](/README.md#high-level-architecture) <br>
[Supported Platforms](/README.md#supported-platforms) <br>
[Topologies](/README.md#topologies) <br>
[Install Configuration](/install.properties)<br>
[Usage](/README.md#usage) <br>
[ICP 3.1.2 - Getting started](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/getting_started/introduction.html)  <br>
[Screenshots](/docs/screenshots) <br>

### **__High Level Architecture__**<br>
<table border="0">
 <tr align="center"><td>An example 4 node topology</td></tr>
 <tr align="center"><td><img src="/docs/screenshots/arch/icp-lxd-4-node-arch.png"></td></tr>
</table> <br>


### **__Supported platforms__**<br>
<table>
 <tr>
   <th align="center">Host</th>
   <th align="center">Guest VM</th>
   <th align="center">ICP-CE</th>
   <th align="center">LXD</th>  
   <th align="center">Min. Compute Power</th>
   <th align="center">User Privileges</th>
</tr>
 <tr>
    <td align="center">Ubuntu 18.04</td>
    <td align="center">Ubuntu 18.04</td>
    <td align="center">3.1.2</td>
    <td align="center">3.0.3 (apt)</td>  
    <td align="center">8Core 16GB-RAM 300GB-Disk</td>  
    <td align="center">root/sudoer</td>  
</tr>
</table> <br>

### **__Topologies__**<br>
<table>
 <tr>
   <th>Boot (B)</th>
   <th>Master/Etcd (ME)</th>
   <th>Management (M)</th>
   <th>Proxy (P)</th>
   <th>Worker (W)</th>
 </tr>
 <tr>
    <td colspan="4" align="center">1 (B/ME/M/P)</td>
    <td align="center">1+*</td>
 </tr>

 <tr>
   <td colspan="3" align="center">1 (B/ME/M)</td>
   <td align="center">1</td>
   <td align="center">1+*</td>
 </tr>
 <tr>
   <td colspan="2" align="center">1 (B/ME) </td>
   <td align="center">1</td>
   <td align="center">1</td>
   <td align="center">1+*</td>
 <tr>
  <td colspan="5">*Set desired worker node count in install.properties before setting up cluster.</td>
 </tr>
 <tr>
    <td colspan="5">Supported topologies based on <a href="https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/getting_started/architecture.html)">ICP Architecture</a></td>
 <tr>
    <td colspan="5">ICP Community Edition does not support HA. Master, Management and Proxy nodes count must always be 1</td>
 </tr>
</table> <br>

### **__Usage__**<br>

#### **__Install properties:__**<br>

      For simplified setup, there is one single install.properites file, that will cover configuration for CLIs, LXD and ICP.

      Examples:
      ## Use y to create separate Proxy, Management Nodes
      PROXY_NODE=y
      MGMT_NODE=y

      ## If for some reason public/external IP lookup fails or gets incorrect address,
      ## set lookup to 'n', manually provide IP  addresses and then re-create cluster
      ICP_AUTO_LOOKUP_HOST_IP_ADDRESS_AS_LB_ADDRESS=y
      ICP_MASTER_LB_ADDRESS=none
      ICP_PROXY_LB_ADDRESS=none

      ## Enable/Disable management services ####
      ICP_MGMT_SVC_CUST_METRICS=enabled
      ICP_MGMT_SVC_IMG_SEC_ENFORCE=enabled
      ICP_MGMT_SVC_METERING=enabled
      ...

      ## Used for console/scripted login, provide your choice of username and password
      ## Default namespace will be added to auto-generated login helper script
      ICP_DEFAULT_NAMESPACE=default
      ICP_DEFAULT_ADMIN_USER=admin
      ICP_DEFAULT_ADMIN_PASSWORD=xxxxxxx


#### **__Create cluster:__**<br>


     Usage:    ./create_cluster.sh [options]
                  -es or --env-short : Environment name in short. ex: test, dev, demo etc.
                  -f  or --force     : [yY]|[yY][eE][sS] or n. Delete cluster LXD components from past install.
                  -h  or --host      : Provide host type information: pc (default), vsi, fyre, aws or othervm.
                  help               : Print this usage.

      Examples: ./create_cluster.sh --host=fyre
                ./create_cluster.sh --host=fyre -f
                ./create_cluster.sh -es=demo --force --host=pc

      Important Notes:
         It is imporant to use use right `host` parameter depending upon the host machine/vm.
         LXD cluster uses internal and private subnet. To expose this cluster, HAProxy is installed and configured by default to enable remote access.
         Make sure to use `static external IP`.
         If IP is changed after build, remote access to cluster will fail and thus will require a new build.
         See architecture diagram for more information

#### **__Download `cloudctl` and `helm` clis__:**<br>

     ./download_icp_cloudctl_helm.sh

#### **__Login into cluster:__**<br>

     ./icp-login-3.1.2-ce.sh
     or
     cloudctl login -a https://<internal_master_ip>:8443 -u <default_admin_user> -p <default_admin_user> -c id-devicpcluster-account -n default --skip-ssl-validation
     or
     cloudctl login -a https://<public_ip>:8443 -u <default_admin_user> -p <default_admin_user> -c id-devicpcluster-account -n default --skip-ssl-validation

#### **__Destory Cluster:__**<br>

     ./destroy-cluster.sh (Deletes lxd cluster w/ ICP-CE. Use with caution)

#### **__Setting up LXD based NFS Server:__** (Optional)<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[NFS Server on Linux Container](https://github.com/HSBawa/nfs-server-on-linux-container)

### **__Post install__**<br>

<table border="0">
  <tr align="center"><td><img src="/docs/screenshots/install/icp-install-finish.png"></td></tr>
  <tr align="center"><td><img src="/docs/screenshots/install/k8s-nodes.png"></td></tr>
  <tr align="center"><td><img src="/docs/screenshots/install/lxd-node-list.png"></td></tr>  
  <tr align="center"><td><img src="/docs/screenshots/install/icp-login.png"></td></tr>
  <tr align="center"><td><img src="/docs/screenshots/install/icp-dashboard.jpg"></td></tr>
</table> <br>
