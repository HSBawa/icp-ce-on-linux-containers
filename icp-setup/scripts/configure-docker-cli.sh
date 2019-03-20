#/bin/bash

INSTALL_PROPERTIES="./install.properties"
CLUSTER_PROPERTIES="./cluster.properties"
CRT_DIR=""
CA_DOMAIN=""

function read_properties(){
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
    echo "Missing cluster properties file ${CLUSTER_PROPERTIES}. Exiting now."
    exit -1
  fi
}

## configure_docker_cli.sh ${ICP_ENV_NAME_SHORT}
function initialize(){
  if [[ ${ICP_USE_ROUTER_KEY} =~ ^([yY][eE][sS]|[yY])+$ ]] && [[ ! -z ${ICP_ROUTER_CA_DOMAIN} ]]; then
    CA_DOMAIN=${ICP_ROUTER_CA_DOMAIN}
  else
    ## Assuming that ICP CA DOMAIN is {{ cluster_name }}.icp
    ## Tune your logic accordingly
    CA_DOMAIN="${ICP_CLUSTER_NAME}.icp"
  fi
    CRT_DIR="/etc/docker/certs.d/${CA_DOMAIN}:8500"
}

function auth_for_docker_cli(){
   echo "Deleting existing certificate from previous install: "
   sudo rm -rf ${CRT_DIR}
   sudo mkdir -p ${CRT_DIR}
   echo "Pulling certificate from master node: "
   sudo lxc file pull  ${ICP_ENV_NAME_SHORT}-${ICP_MASTER_NAME}-0/${CRT_DIR}/ca.crt ${CRT_DIR}/ca.crt
   echo "Restarting Docker"
   sudo systemctl restart docker
   echo "Done"
}

function validate(){
  CERT="$(ls ${CRT_DIR})"
  if [[ -z  ${CERT} ]]; then
     echo "Certificate didn't get copied to ${CRT_DIR}. Please try again."
     echo "  Command is: lxc file pull  ${ICP_ENV_NAME_SHORT}-${ICP_MASTER_NAME}-0/${CRT_DIR}/ca.crt ${CRT_DIR}/ca.crt"
  else
       echo "Certificate ${CERT} was successfully pulled from master node."
  fi
  echo ""
}

echo ""
echo ">>>>>>>>>>>>>>>>>>> Setting up authentication for host Docker CLI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo ">>>>>>>>>>>>>>>>>>> IF NOT ROOT/SUDOER, PASSWORD MAY BE REQUIRED  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
read_properties
initialize
auth_for_docker_cli
validate
