#!/bin/bash
###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
if [ "$#" -ne 4 ]; then
    echo "Usage: install.sh <icp_cluster_folder> <icp_installer> <icp_version> <icp_log_folder>"
    echo "Usage ex: install.sh /opt/icp-3.1.2-ce/cluster ibmcom/icp-inception 3.1.2 /opt/icp-3.1.2-ce/log"
    exit
fi
ts=$(date +'%Y%m%d-%H%M%S')
echo "Initiating install for ICP v$3"
docker run -e LICENSE=accept --net=host -t -v $1:/installer/cluster $2:$3 install | tee $4/install-$ts.log
