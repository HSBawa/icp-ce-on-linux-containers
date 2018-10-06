###############################################################################
## Use this file to OVERRIDE DEFAULT properties in variables.tf
## hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################

###############################################################################
## Environment properties
###############################################################################
environment = {
    name="ICP-CE Dev"
    ## use for env prefix
    ## Make sure that this prefix is not being used elsewhere.
    ## Use command 'lxc list <name-short>' to view containers
    ## for this clustr
    name_short="dev"
    description="Dev environment for Project ICP"
}

###############################################################################
## Linux Container image for ICP properties
###############################################################################
lxd_image = {
    name="xenial-container-for-icp-lvm-bionic-host"
    remote="local"
    ephemeral=false
}

###############################################################################
## CLuster properties
###############################################################################
cluster = {
     admin_pass="admin_0000"
     proxy_lb_address="none"
     cluster_lb_address="none"
}

###############################################################################
## ICP properties
###############################################################################
icp = {
    tag="3.1.0"
    edition="ce"
    installer="ibmcom/icp-inception"
    ### Debug Install Use Only (true or false)
    install_dbg=false
    min_avail_root_size=10
}
###############################################################################
## Linux Container Network properties
###############################################################################
lxd_network = {
    #ipv4_cidr="10.30.30.1/24,10.20.20.1/24"
    ### Make sure this subnet is not being used elsewhere
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

###############################################################################
## Master Node  properties
###############################################################################
master_node = {
    node_count = 1
    ## $env-name-$nodenumber
    name="master"
    profile_name="master"
    cpu=2
    start_host_num=101
    storage_device_name = "root"
    storage_device_size = "30GB"
    storage_device_path = "/"
    storage_device_pool = "icp"
    storage_device_type = "disk"
}

###############################################################################
## Worker Node  properties
###############################################################################
worker_node = {
    node_count = 2
    cpu=2
    ## $env-name-$nodenumber
    name="worker"
    profile_name="worker"
    start_host_num=201
    storage_device_name = "root"
    storage_device_size = "25GB"
    storage_device_path = "/"
    storage_device_pool = "icp"
    storage_device_type = "disk"
}

###############################################################################
## ICP Docker archives  properties
## Followig options are to load ICP from docker archives
## Use this for airtight environment
###############################################################################
icp_docker_image_archives = {
    enabled="false"
    # Provide absolute path on respective nodes.
    # Following example uses shared folder (host)
    path="/share/icp310ce/icp-ce-310.tar"
}

###############################################################################
## LXD Profile (common) properties
###############################################################################
common_profile = {
    name="common"
}

###############################################################################
## Proxy Node  properties
###############################################################################
proxy_node =  {
    node_count = 1
    cpu=2
    ## $env-name-$nodenumber
    name="proxy"
    profile_name="proxy"
    start_host_num=121
    storage_device_name = "root"
    storage_device_size = "25GB"
    storage_device_path = "/"
    storage_device_pool = "icp"
    storage_device_type = "disk"
}

###############################################################################
## Management Node  properties
###############################################################################
management_node = {
    node_count = 1
    cpu=2
    ## $env-name-$nodenumber
    name="mgmt"
    profile_name="mgmt"
    start_host_num=141
    storage_device_name = "root"
    storage_device_size = "25GB"
    storage_device_path = "/"
    storage_device_pool = "icp"
    storage_device_type = "disk"
}
