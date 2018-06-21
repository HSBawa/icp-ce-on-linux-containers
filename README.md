_If you are looking for official IBM ICP-CE install, you can find it [here](https://github.com/IBM/deploy-ibm-cloud-private)_

Welcome to the IBM Cloud Private CE on Linux Containers Infrastructure As Code (IaC). With the help of this IaC, you easily setup a 8 node Linux Container based ICP cluster on your Linux Desktop or VM itself!!!

Supported ICP-CE versions:
* 2.1.0.2 (Kubernetes v1.9.1) - Installs by default
* 2.1.0.1 (Kubernetes v1.8.3) - Update "icp_tag" variable in [terraform.tfvars](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/terraform.tfvars) 

This IaC will create following LXD components:
* Base image
* [Nodes](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.2/getting_started/architecture.html):
  * Boot   
  * Master
  * Proxy  
  * Management
  * Vulnerability Advisor
  * Worker 1
  * Worker 2
  * Worker 3
* Profiles:
  * Shared profile
  * Custom profile for each node
* Network configuration

Pre-requisite:

This IaC is targeted towards users with intermediate to advanced understanding of Linux Containers. Included script, [lxd_pre-reqs_check.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/lxd_pre-reqs_check.sh), can be used as a guideline to validate that latest LXD and additional required software is installed and setup of on Linux host.

For a complete and end to end setup, you can try [ICP CE on Linux Containers on Virtual Box](https://github.com/HSBawa/icp-ce-on-linux-containers-vb). This IaC will configure and setup Linux Containers (LXD) on a Ubuntu Virtual Box rather than directly on your host.

    
Documentation

Ubuntu Bionic compatibility note:

* [Tips on getting started with LXD on your Linux Host](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/Getting-started-with-LXD-on-your-Linux-Host-(Ubuntu))
  * Current IaC was tested on Ubuntu Xenial (16.04) and Artful (17.10) (host and lxd images only) and will not work on Bionic (18.04) AS-IS.
  * If you have installed LXD via snap, you may see following error:_unix /var/lib/lxd/unix.socket: connect: no such file or directory_.[Workaround](https://github.com/sl1pm4t/terraform-provider-lxd/issues/133)
* [1.0 Create Base Linux Container image for IBM Cloud Private-CE nodes with Hashicorp Packer](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/1.0-Create-Base-Linux-Container-Image-For-IBM-Cloud-Private-with-Hashicorp-Packer)
* [2.0 Create Linux Container cluster and start IBM Cloud Private-CE install with Terraform](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/2.0-Create-LXD-Cluster-and-ICP-install-with-Terraform)
* [3.0 Manual Install and uninstall process for IBM Cloud Private-CE on Linux Container cluster](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/3.0-ICP-CE-install-and-uninstall-process-on-LXD-cluster)
* [4.0 Setup Helm for IBM Cloud Private](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/4.0-Setting-up-Helm-for-IBM-Cloud-Private)
* [5.0 Setup NFS volume as PersistentVolume (PV) on IBM Cloud Private](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/5.0-Setup--NFS-volume-as-PersistentVolume-(PV)-on-IBM-Cloud-Private)
* [6.0 Installing Cloud Automation Manager (CAM)  Community Edition Online](https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.2/cam_install_CE.html)



[View Screenshots](https://github.com/HSBawa/icp-ce-on-linux-containers/tree/master/docs/screenshots)

Helpful Scripts:
* [lxd_pre-reqs_check.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/lxd_pre-reqs_check.sh) 
  * Checks if needed software is installed on host system
* [install-w-terra.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/install-w-terra.sh)
  * Initiates terraform scripts for cluster creation and icp install process
  * ![ICP 2.1.0.2 Successful Install - 1](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/docs/screenshots/2.1.0.2/icp-2102-successful-install.png)
  * ![ICP 2.1.0.2 Successful Install - 2](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/docs/screenshots/2.1.0.2/icp-2102-successful-install-2.png)
* [terra-clean.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/terra-clean.sh)
  * Deletes current terraform state data in that folder
* [icp-install-clis.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/icp-install-clis.sh) 
  * Helpful script to download supporting CLI's.
    * Kubectl, ICP Helm, IBM Cloud (bx), ICP Plugin (icp-linux-amd64)
  * If you are not using default master ip, update script accordingly before usage.
* [icp-login-2.1.0.2-ce.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/icp-login-2.1.0.2-ce.sh) 
  * This is an example file. Actual file is auto-generated on successful install to simplify and automate ICP login process. 
  * Pre-Requisite: [kubectl](https://v1-9.docs.kubernetes.io/docs/tasks/tools/install-kubectl/) (v1.8.3+ for ICP 2.1.0.1, 1.9.1+ for ICP 2.1.0.2), [IBM Cloud CLI](https://console.bluemix.net/docs/cli/reference/bluemix_cli/download_cli.html#download_install) and [ICP plugin](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.2/manage_cluster/install_cli.html) installed.
  * ![ICP 2.1.0.2 Login Script](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/docs/screenshots/2.1.0.2/icp-login-script-example.png)
* [running_processes.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/running_process.sh)
  * Checks if all pods (by count) are up and running on master node
* [destroy-cluster-manual.sh](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/destroy-cluster-manual.sh)
  * If for any reason, terraform is not able to destroy Linux container cluster, use this script to do so manually and clean up the configuration. 
  * If env_prefix, network or node name are changed, update script accordingly.
* [Pull and Tar ICP-CE docker images manually](https://github.com/HSBawa/icp-ce-on-linux-containers/tree/master/icp-docker-img-scripts)
  * These scripts can help retrieve all key ICP-CE Docker images and create tar archives. Images can also be added to private Docker registry for internal access.
  * To use tar archives or private registry, update [terraform.tfvars](https://github.com/HSBawa/icp-ce-on-linux-containers/blob/master/terraform.tfvars) accordingly or disable them (default) to pull directly from ibmcom during install process. 

