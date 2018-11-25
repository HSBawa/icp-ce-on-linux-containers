#!/bin/bash

MASTER_VM="dev-master-0"
ADD_URL_SCRIPT="addclusteraccessurl.sh"
REMOVE_URL_SCRIPT="removeclusteraccessurl.sh"
DEFAULT_URL_TMPL="platform-oidc-registration.json.orig.tmpl"
ADD_URL_TMPL="platform-oidc-registration.json.tmpl"
CFC_COMP_DIR="/opt/icp-3.1.0-ce/cluster/cfc-components"
BIN_DIR="/opt/icp-3.1.0-ce/bin"

function set_master_vm(){
   if [[ ! -z "$1"  ]]; then
      MASTER_VM="$1"	
   fi
}

function copy_exec_files(){
   lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ${ADD_URL_SCRIPT} ${MASTER_VM}/${BIN_DIR}/${ADD_URL_SCRIPT}
   lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ${ADD_URL_SCRIPT} ${MASTER_VM}/${BIN_DIR}/${REMOVE_URL_SCRIPT}
}

function copy_template_files(){
   lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ${DEFAULT_URL_TMPL} ${MASTER_VM}/${CFC_COMP_DIR}/${DEFAULT_URL_TMPL}
   lxc file push --create-dirs=true --gid=0 --uid=0 --mode="0744" ${ADD_URL_TMPL} ${MASTER_VM}/${CFC_COMP_DIR}/${ADD_URL_TMPL}
}

set_master_vm $1
echo "Master node name: $MASTER_VM"
echo ""
echo "Pushing file ${ADD_URL_SCRIPT} and ${REMOVE_URL_SCRIPT} to ${MASTER_VM}"
copy_template_files
echo ""
echo "Pushing file ${DEFAULT_URL_TMPL}  and ${ADD_URL_TMPL} to ${MASTER_VM}"
echo ""
copy_exec_files
