
###############################################################################
## Environment properties
###############################################################################
variable "environment"{
    type = "map"
    default = {
        name="ICP-CE Development"
        ## use for env prefix
        name_short="test"
        description="Development environment for Project ICP"
    }
}

###############################################################################
## Linux Container for ICP properties
###############################################################################
variable "lxd"{
    type = "map"
    default = {
        image="xenial-container-for-icp-lvm-bionic-host"
        ## Remote 'local' will not work with LXD installed with APT
        ##remote="local"
        ## Remote 'local-https' works with LXD installed with APT or SNAP       
        remote="local-https"
        ephemeral=false
    }
}

###############################################################################
## CLuster properties
###############################################################################
variable "cluster"{
    type = "map"
    default = {
        minimal=true
        name="devicpcluster"
        domain="cluster.local"
        CA_domain="{{ cluster_name }}.icp"
        admin_user="admin"
        admin_pass="admin_1111"
        default_namespace="default"
        proxy_lb_address="none"
        cluster_lb_address="none"
        #######################################################################
        ## ICP 3.1 Supported Management Servcies
        ##     custom-metrics-adapter, image-security-enforcement, istio,
        ##     metering, monitoring, service-catalog, storage-minio,
        ##     storage-glusterfs, vulnerability-advisor
        #######################################################################
        disabled_management_services="istio vulnerability-advisor storage-glusterfs storage-minio metering monitoring custom-metrics-adapter"
    }
}

###############################################################################
## ICP properties
###############################################################################
variable "icp"{
    type = "map"
    default = {
        tag="3.1.0"
        edition="ce"
        installer="ibmcom/icp-inception"
        ### Debug Install Use Only (true or false)
        install_dbg=false
        min_avail_root_size=20
    }
}
###############################################################################
## Linux Container Network properties
###############################################################################
variable "lxd_network"{
    type = "map"
    default = {
        #ipv4_cidr="10.30.30.1/24,10.20.20.1/24"
        ipv4_cidr="10.50.50.1/24"
        ipv6_cidr="none"
        ipv4_nat=true
        ipv6_nat=false
        name="br"
        device_name="eth0"
        ## if not using device type 'nic', update strcuture and related code accordingly
        device_type="nic"
        ## nic type values: physical, bridged, macvlan, p2p and sriov
        nic_type="bridged"
    }
}

###############################################################################
## Master Node  properties
###############################################################################
variable "master_node" {
  type = "map"
  default = {
    node_count = 1
    ## $env-name-$nodenumber
    name="master"
    profile_name="master"
    cpu=2
    start_host_num=101
    storage_device_name = "root"
    storage_device_size = "30GB"
    storage_device_path = "/"
    storage_device_pool = "default"
    storage_device_type = "disk"
  }
}

###############################################################################
## Worker Node  properties
###############################################################################
variable "worker_node" {
  type = "map"
  default = {
    node_count = 2
    cpu=2
    ## $env-name-$nodenumber
    name="worker"
    profile_name="worker"
    start_host_num=201
    storage_device_name = "root"
    storage_device_size = "30GB"
    storage_device_path = "/"
    storage_device_pool = "default"
    storage_device_type = "disk"
  }
}

###############################################################################
## ICP Docker archives  properties
## Followig options are to load ICP from docker archives
## Use this for airtight environment
###############################################################################
variable "icp_docker_image_archives" {
    type = "map"
    default = {
        enabled="false"
        # Provide absolute path on respective nodes.
        # Following example uses shared folder (host)
        path="/share/icp310ce/icp-ce-310.tar"
    }
}

###############################################################################
## LXD Profile (common) properties
###############################################################################
variable "common_profile"{
    type = "map"
    default={
        name="common"
    }
}

###############################################################################
## Proxy Node  properties
###############################################################################
variable "proxy_node" {
  type = "map"
  default = {
    node_count = 1
    cpu=2
    ## $env-name-$nodenumber
    name="proxy"
    profile_name="proxy"
    start_host_num=121
    storage_device_name = "root"
    storage_device_size = "30GB"
    storage_device_path = "/"
    storage_device_pool = "default"
    storage_device_type = "disk"
  }
}

###############################################################################
## Management Node  properties
###############################################################################
variable "management_node" {
  type = "map"
  default = {
    node_count = 1
    cpu=2
    ## $env-name-$nodenumber
    name="mgmt"
    profile_name="mgmt"
    start_host_num=141
    storage_device_name = "root"
    storage_device_size = "30GB"
    storage_device_path = "/"
    storage_device_pool = "default"
    storage_device_type = "disk"
  }
}
