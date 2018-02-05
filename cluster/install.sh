#!/bin/bash
###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
docker run -e LICENSE=accept --net=host -t -v /opt/icp-2101-ce/cluster:/installer/cluster ibmcom/icp-inception:2.1.0.1 install
