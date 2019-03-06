#!/bin/bash


INSTALL_PROPERTIES="./install.properties"
ICP_HAPROXY_MP_TMPL=""
ICP_HAPROXY_MP_FILE=""
ICP_HAPROXY_M_TMPL=""
ICP_HAPROXY_M_FILE=""
HAPROXY_ICP_MARKER_START="## MARKER START @@ICP_CONFIG@@"
HAPROXY_ICP_MARKER_END="## MARKER END @@ICP_CONFIG@@"
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"


function  read_properties() {
  while IFS== read -r KEY VALUE
  do
      if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
        export "$KEY=$VALUE"
      fi
  done < ${INSTALL_PROPERTIES}
}

function  initialize(){
  ICP_HAPROXY_MP_TMPL=${ICP_SETUP_FOLDER}/haproxy/haproxy-mp.cfg.tmpl
  ICP_HAPROXY_MP_FILE=${ICP_SETUP_FOLDER}/haproxy/haproxy-mp.cfg
  ICP_HAPROXY_M_TMPL=${ICP_SETUP_FOLDER}/haproxy/haproxy-m.cfg.tmpl
  ICP_HAPROXY_M_FILE=${ICP_SETUP_FOLDER}/haproxy/haproxy-m.cfg
}

function update_haproxy_cfg(){
  if [[ ${SETUP_HAPROXY_ICP} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    ## Clear existing configuration
    if grep -Fxq "${HAPROXY_ICP_MARKER_START}" ${HAPROXY_CFG} && grep -Fxq "${HAPROXY_ICP_MARKER_END}" ${HAPROXY_CFG}
      then
        echo "Configuration exists. Overwriting ..."
        lineNumStart="$(grep -n "${HAPROXY_ICP_MARKER_START}" ${HAPROXY_CFG} | head -n 1 | cut -d: -f1)"
        lineNumEnd="$(grep -n "${HAPROXY_ICP_MARKER_END}" ${HAPROXY_CFG} | head -n 1 | cut -d: -f1)"
        sudo sed -i "${lineNumStart},${lineNumEnd}d" ${HAPROXY_CFG}
    fi

    MASTER_NODE_NAME=${ICP_ENV_NAME_SHORT}-${ICP_MASTER_NAME}-0
    MASTER_NODE_IP=$(lxc exec ${MASTER_NODE_NAME} -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
    if [[ ${PROXY_NODE} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
      PROXY_NODE_NAME=${ICP_ENV_NAME_SHORT}-${ICP_PROXY_NAME}-0
      PROXY_NODE_IP=$(lxc exec ${PROXY_NODE_NAME} -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
      sed -e 's|@@MASTER_NODE_NAME@@|'"${MASTER_NODE_NAME}"'|g' \
          -e 's|@@MASTER_NODE_IP@@|'"${MASTER_NODE_IP}"'|g' \
          -e 's|@@PROXY_NODE_NAME@@|'"${PROXY_NODE_NAME}"'|g' \
          -e 's|@@PROXY_NODE_IP@@|'"${PROXY_NODE_IP}"'|g' < ${ICP_HAPROXY_MP_TMPL} >> ${HAPROXY_CFG}
          # -e 's|@@PROXY_NODE_IP@@|'"${PROXY_NODE_IP}"'|g' < ${ICP_HAPROXY_MP_TMPL} > ${ICP_HAPROXY_MP_FILE}
      # cat ${ICP_HAPROXY_MP_FILE} >> ${HAPROXY_CFG}
    else
      sed -e 's|@@MASTER_NODE_NAME@@|'"${MASTER_NODE_NAME}"'|g' \
          -e 's|@@MASTER_NODE_IP@@|'"${MASTER_NODE_IP}"'|g' < ${ICP_HAPROXY_MP_TMPL} >> ${HAPROXY_CFG}
      # cat ${ICP_HAPROXY_M_FILE} >> ${HAPROXY_CFG}
    fi
    cat ${HAPROXY_CFG}
    sleep 5
    sudo systemctl restart haproxy.service
  fi
}

read_properties
initialize
update_haproxy_cfg
