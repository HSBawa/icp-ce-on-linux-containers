#!/bin/bash
###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################

if [ "$#" -ne 4 ]; then
    echo "Usage: install-dbg.sh <icp_cluster_folder> <icp_installer> <icp_version> <icp_log_folder>"
    echo "Usage ex: install-dbg.sh /opt/icp-2.1.0.1-ce/cluster ibmcom/icp-inception 2.1.0.1 /opt/icp-2.1.0.1-ce/log"
    exit
fi
ts=$(date +'%Y%m%d-%H%M%S')
echo "Initiating install debug for ICP $3"
docker run -e LICENSE=accept --net=host -t -v $1:/installer/cluster $2:$3 install -vvv | tee $4/install-dbg-$ts.log
