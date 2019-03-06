#!/bin/bash

##############################################################################
# install-clis.sh
# Reads install.properties file for new variables or variable override.
# Variable names keep in upper case (or starts with upper case)
##############################################################################

TERRA_LXD_PLUGIN_LOC="${HOME}/.terraform.d/plugins/linux_amd64"

function  read_properties() {
  while IFS== read -r KEY VALUE
  do
      if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
        export "$KEY=$VALUE"
      fi
  done < ./install.properties
}

function install_terraform_plugin_for_lxd(){
  if [[ ${INSTALL_TERRAFORM_LXD_PLUGIN} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
    mkdir -p ${TERRA_LXD_PLUGIN_LOC}
    TERRA_LXD_ZIP="terraform-provider-lxd_${TERRA_LXD_VERSION}_linux_amd64.zip"
    TERRA_LXD_URL="https://github.com/sl1pm4t/terraform-provider-lxd/releases/download/${TERRA_LXD_VERSION}/${TERRA_LXD_ZIP}"
    echo ""
    echo "Installing Terraform Plugin for LXD  ${TERRA_LXD_VERSION} ... "
    wget -nv -q ${TERRA_LXD_URL} -O  ${TEMP_FOLDER}/${TERRA_LXD_ZIP}
    unzip -o ${TEMP_FOLDER}/${TERRA_LXD_ZIP} -d ${TERRA_LXD_PLUGIN_LOC} &> /dev/null
    rm ${TEMP_FOLDER}/${TERRA_LXD_ZIP} &> /dev/null
    echo "Done"
    echo "$(ls -a ${TERRA_LXD_PLUGIN_LOC})"
    echo ""

  fi
}

function install_terraform(){
  if [[ ${INSTALL_TERRAFORM} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
    EXISTS="$(which terraform)"
    if [[ -z ${EXISTS} ]] || [[ ${OVERWRITE_CLIS} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
      TERRAFORM_ZIP=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
      TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}"
      echo ""
      echo "Installing Terraform version ${TERRAFORM_VERSION} ... "
      curl -fso ${TEMP_FOLDER}/${TERRAFORM_ZIP} ${TERRAFORM_URL}
      sudo unzip -o ${TEMP_FOLDER}/${TERRAFORM_ZIP} -d ${CLI_LOC} &> /dev/null
      sudo chmod +x ${CLI_LOC}/terraform
      rm ${TEMP_FOLDER}/${TERRAFORM_ZIP} &> /dev/null
      echo "Done."
      echo "$(which terraform)"
      echo ""
    else
      echo "Terraform already installed."
    fi
  fi
}

function install_packer(){
  if [[ ${INSTALL_PACKER} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
    EXISTS="$(which packer)"
    if [[ -z ${EXISTS} ]] || [[ ${OVERWRITE_CLIS} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
      PACKER_ZIP="packer_${PACKER_VERSION}_linux_amd64.zip"
      PACKER_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/${PACKER_ZIP}"
      echo ""
      echo ""
      echo "Installing Packer version ${PACKER_VERSION} ... "
      curl -fso ${TEMP_FOLDER}/${PACKER_ZIP} ${PACKER_URL}
      sudo unzip -o ${TEMP_FOLDER}/${PACKER_ZIP} -d ${CLI_LOC} &> /dev/null
      sudo chmod +x ${CLI_LOC}/packer
      rm ${TEMP_FOLDER}/${PACKER_ZIP} &> /dev/null
      echo "Done."
      echo "$(which packer)"
      echo ""
    else
      echo "Packer already installed."
    fi
  fi
}

function install_docker(){
  if [[ ${INSTALL_DOCKER} =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    EXISTS="$(which docker)"
    if [[ -z ${EXISTS} ]] || [[ ${OVERWRITE_CLIS} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
      echo ""
      echo "Installing Docker (latest) ... "
      curl -o ${TEMP_FOLDER}/get-docker.sh -fsSL get.docker.com &> /dev/null
      sudo sh ${TEMP_FOLDER}/get-docker.sh &> /dev/null
      usermod -aG docker root &> /dev/null
      if [[ "root" != "${USER}" ]]; then
        usermod -aG docker ${IUSER} &> /dev/null
      fi
      echo "Done."
      echo ""
      echo "$(which docker)"
      echo ""
    else
      echo "Docker already installed."
    fi
  fi
}


function install_kubectl(){
  if [[ ${INSTALL_KUBECTL} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
    EXISTS="$(which kubectl)"
    if [[ -z ${EXISTS} ]] || [[ ${OVERWRITE_CLIS} =~ ^([yY][eE][sS]|[yY])+$  ]]; then
      if [[ -z "${KUBECTL_VERSION}" ]]; then
         KUBECTL_VERSION="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
      fi
      KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl

      echo ""
      echo "Installing Kubectl version ${KUBECTL_VERSION} ... "
      curl -fso ${TEMP_FOLDER}/kubectl ${KUBECTL_URL} >& /dev/null
      chmod +x ${TEMP_FOLDER}/kubectl >& /dev/null
      sudo mv ${TEMP_FOLDER}/kubectl ${CLI_LOC}/kubectl >& /dev/null
      echo "Done."
      echo "$(which kubectl)"
      echo ""
    else
      echo "Kubectl already installed."
    fi
  fi
}

read_properties
install_terraform_plugin_for_lxd
install_terraform
install_kubectl
install_packer
