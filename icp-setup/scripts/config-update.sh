#!/bin/bash

INSTALL_PROPERTIES="./install.properties"
CLUSTER_PROPERTIES="./cluster.properties"
HOST_IP_ADDRESS=""

function get_ip_address(){
  ## Mostly VM Devices
  if [[  "${LXD_HOST}" =~ ^(vsi|fyre|aws|othervm)+$ ]]; then
    HOST_IP_ADDRESS="$(hostname -I | cut -d' ' -f2)"
  elif [[ "${LXD_HOST}" =~ ^(pc)+$ ]]; then
    HOST_IP_ADDRESS="$(hostname -I | cut -d' ' -f1)"
  else
    HOST_IP_ADDRESS="none"
  fi
}

function  read_properties() {
  if [[ -f "${INSTALL_PROPERTIES}" ]]; then
    while IFS== read -r KEY VALUE
    do
        if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
          export "$KEY=$VALUE"
        fi
    done < ${INSTALL_PROPERTIES}
  else
    echo "Missing install properties file ${INSTALL_PROPERTIES}. Exiting now."
    exit -1
  fi

  if [[ -f "${CLUSTER_PROPERTIES}" ]]; then
    while IFS== read -r KEY VALUE
    do
        if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
          export "$KEY=$VALUE"
        fi
    done < ${CLUSTER_PROPERTIES}
  else
    echo "Missing install properties file ${CLUSTER_PROPERTIES}. Exiting now."
    exit -1
  fi

}

function update_config(){
    ICP_CONFIG_TMPL_FILE="${ICP_SETUP_FOLDER}/cluster/${ICP_CONFIG_YAML_TMPL_FILE}"
    ICP_CONFIG_FILE="${ICP_SETUP_FOLDER}/cluster/config.yaml"

    echo ">>>>>>>>>>>>>>>[Update ICP Config YAML : ${ICP_CONFIG_FILE}]"
    ICP_CLUSTER_NAME="${ICP_ENV_NAME_SHORT}icpcluster"
    echo "ICP_CLUSTER_NAME=${ICP_CLUSTER_NAME}" >> ${CLUSTER_PROPERTIES}

    if [[ ${ICP_AUTO_LOOKUP_HOST_IP_ADDRESS_AS_LB_ADDRESS} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
        ICP_MASTER_LB_ADDRESS=${HOST_IP_ADDRESS}
        echo "ICP_MASTER_LB_ADDRESS=${ICP_MASTER_LB_ADDRESS}" >> ${CLUSTER_PROPERTIES}
        if [[ ${PROXY_NODE} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
          ICP_PROXY_LB_ADDRESS=${HOST_IP_ADDRESS}
          echo "ICP_PROXY_LB_ADDRESS=${ICP_PROXY_LB_ADDRESS}" >> ${CLUSTER_PROPERTIES}
        fi
    fi

    sed -e 's|@@ICP_CLUSTER_DOMAIN@@|'"${ICP_CLUSTER_DOMAIN}"'|g' \
        -e 's|@@ICP_CLUSTER_NAME@@|'"${ICP_CLUSTER_NAME}"'|g' \
        -e 's|@@ICP_CLUSTER_CA_DOMAIN@@|'"${ICP_CLUSTER_CA_DOMAIN}"'|g' \
        -e 's|@@ICP_DEFAULT_ADMIN_USER@@|'"${ICP_DEFAULT_ADMIN_USER}"'|g' \
        -e 's|@@ICP_DEFAULT_ADMIN_PASSWORD@@|'"${ICP_DEFAULT_ADMIN_PASSWORD}"'|g' \
        -e 's|@@ICP_PASSWORD_RULE_PATTERN@@|'"${ICP_PASSWORD_RULE_PATTERN}"'|g' \
        -e 's|@@ICP_KUBE_PROXY_EXTRA_ARGS@@|'"${ICP_KUBE_PROXY_EXTRA_ARGS}"'|g' \
        -e 's|@@ICP_BOOTSTRAP_TOKEN_TTL@@|'"${ICP_BOOTSTRAP_TOKEN_TTL}"'|g' \
        -e 's|@@ICP_MASTER_LB_ADDRESS@@|'"${ICP_MASTER_LB_ADDRESS}"'|g' \
        -e 's|@@ICP_PROXY_LB_ADDRESS@@|'"${ICP_PROXY_LB_ADDRESS}"'|g' \
        -e 's|@@ICP_MGMT_SVC_ISTIO@@|'"${ICP_MGMT_SVC_ISTIO}"'|g' \
        -e 's|@@ICP_INGRESS_HTTP_PORT@@|'"${ICP_INGRESS_HTTP_PORT}"'|g' \
        -e 's|@@ICP_INGRESS_HTTPS_PORT@@|'"${ICP_INGRESS_HTTPS_PORT}"'|g' \
        -e 's|@@ICP_MGMT_SVC_VA@@|'"${ICP_MGMT_SVC_VA}"'|g' \
        -e 's|@@ICP_MGMT_SVC_GFS@@|'"${ICP_MGMT_SVC_GFS}"'|g' \
        -e 's|@@ICP_MGMT_SVC_MINIO@@|'"${ICP_MGMT_SVC_MINIO}"'|g' \
        -e 's|@@ICP_MGMT_SVC_NETPOLS@@|'"${ICP_MGMT_SVC_NETPOLS}"'|g' \
        -e 's|@@ICP_MGMT_SVC_DRAINO@@|'"${ICP_MGMT_SVC_DRAINO}"'|g' \
        -e 's|@@ICP_MGMT_SVC_MC_HUB@@|'"${ICP_MGMT_SVC_MC_HUB}"'|g' \
        -e 's|@@ICP_MGMT_SVC_MC_EP@@|'"${ICP_MGMT_SVC_MC_EP}"'|g' \
        -e 's|@@ICP_MGMT_SVC_CUST_METRICS@@|'"${ICP_MGMT_SVC_CUST_METRICS}"'|g' \
        -e 's|@@ICP_MGMT_SVC_IMG_SEC_ENFORCE@@|'"${ICP_MGMT_SVC_IMG_SEC_ENFORCE}"'|g' \
        -e 's|@@ICP_MGMT_SVC_METERING@@|'"${ICP_MGMT_SVC_METERING}"'|g' \
        -e 's|@@ICP_MGMT_SVC_LOGGING@@|'"${ICP_MGMT_SVC_LOGGING}"'|g' \
        -e 's|@@ICP_MGMT_SVC_MONITORING@@|'"${ICP_MGMT_SVC_MONITORING}"'|g' \
        -e 's|@@ICP_MGMT_SVC_CATALOG@@|'"${ICP_MGMT_SVC_CATALOG}"'|g' \
        -e 's|@@ICP_ELASTIC_SEARCH_METRIC_MAX_AGE@@|'"${ICP_ELASTIC_SEARCH_METRIC_MAX_AGE}"'|g' \
        -e 's|@@ICP_ELASTIC_SEARCH_LOG_MAX_AGE@@|'"${ICP_ELASTIC_SEARCH_LOG_MAX_AGE}"'|g' < "${ICP_CONFIG_TMPL_FILE}" > "${ICP_CONFIG_FILE}"
    echo ""
}

#print_input
read_properties
get_ip_address
update_config
