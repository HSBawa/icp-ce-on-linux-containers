Welcome to the IBM Cloud Private CE on Linux Containers Infrastructure As Code (IaC). With the help of this IaC, you easily setup a multi node Linux Container based ICP cluster on your Linux Desktop or VM!!!

Supported ICP-CE versions: 3.1.0

This IaC will create following Nodes for Community Edition:
* [Nodes](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/getting_started/architecture.html):
  * 1 Master - 2 Worker Nodes (w/ (M)inimal install
  * 1 Master, 1 Proxy. 1 Management and 2 Worker Nodes (w/ (F)ull install)
  * Note: Worker node count can be changed (1..n) in terraform.tfvars before install.

Documentation (update in progress):
* [Tips on getting started with LXD on your Linux Host](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/Getting-started-with-LXD-on-your-Linux-Host-(Ubuntu))
* [1.0 Create Base Linux Container image for IBM Cloud Private-CE nodes with Hashicorp Packer](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/1.0-Create-Base-Linux-Container-Image-For-IBM-Cloud-Private-with-Hashicorp-Packer)
* [2.0 Create Linux Container cluster and start IBM Cloud Private-CE install with Terraform](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/2.0-Create-LXD-Cluster-and-ICP-install-with-Terraform)
* [3.0 Manual Install and uninstall process for IBM Cloud Private-CE on Linux Container cluster](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/3.0-ICP-CE-install-and-uninstall-process-on-LXD-cluster)
* [4.0 Setup Helm for IBM Cloud Private](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/4.0-Setting-up-Helm-for-IBM-Cloud-Private)
* [5.0 Setup NFS volume as PersistentVolume (PV) on IBM Cloud Private](https://github.com/HSBawa/icp-ce-on-linux-containers/wiki/5.0-Setup--NFS-volume-as-PersistentVolume-(PV)-on-IBM-Cloud-Private)

[View Screenshots](https://github.com/HSBawa/icp-ce-on-linux-containers/tree/master/docs/screenshots/3.1.0)
