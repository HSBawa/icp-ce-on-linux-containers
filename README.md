Welcome to the IBM Cloud Private CE on Linux Containers IaC !!!
Yes, you can easily run 7 Node ICP Cluster on your Linux Desktop or VM itself!!!

**Documentation**
* [1.0 Create Base Linux Container image with Hashicorp Packer](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/1.0-Create-Base-Linux-Container-Image-For-IBM-Cloud-Private-with-Hashicorp-Packer)
* [2.0 Create Linux Container cluster and start ICP install with Terraform](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/2.0-Create-LXD-Cluster-and-ICP-install-with-Terraform)
* [3.0 Manual ICP CE install and uninstall process on Linux Container cluster](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/3.0-ICP-CE-install-and-uninstall-process-on-LXD-cluster)

**[Screenshots](https://github.com/HSBawa/icp-ce-on-linux-containers/tree/master/docs/screenshots)**

**Helpful Scripts:**
* [lxd_pre-reqs_check.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/lxd_pre-reqs_check.sh) 
  * Checks if needed software is installed on host system
* [install-w-terra.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/install-w-terra.sh)
  * Initiates terraform scripts for cluster creation and icp install process
* [terra-clean.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/terra-clean.sh)
  * Deletes current terraform state data in that folder
* [icp-login.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/icp-login.sh) 
  * Simplifies and automates ICP login process. Requires IBM Cloud CLI and ICP plugin installed.
* [running_processes.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/running_process.sh)
  * Checks if all pods (by count) are up and running on master node
* [destroy-cluster-manual.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/destroy-cluster-manual.sh)
  * If for any reason, terraform is not able to destroy Linux container cluster, use this script to do so manually and clean up the configuration. 
  * If env_prefix, network or node name are changed, update script accordingly.
