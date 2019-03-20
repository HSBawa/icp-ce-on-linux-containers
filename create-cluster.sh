#!/bin/bash

##############################################################################
# install.sh
##############################################################################

INSTALL_PROPERITES="./install.properties"

args=($@)

function  read_properties() {
  while IFS== read -r KEY VALUE
  do
      if [[ "${KEY:0:1}" =~ ^[A-Z]$ ]]; then
        export "$KEY=$VALUE"
      fi
  done < ${INSTALL_PROPERITES}
}


function help(){
  echo ""
  echo "Any command options passed with install will update 'install.properties' file accordingly."
  echo "Usage:    ./create_cluster.sh [options]"
  echo "                -es or --env-short : Environment name in short. ex: test, dev, demo etc"
  echo "                -f  or --force     : [yY]|[yY][eE][sS] or n. Delete any components from past install, if they conflict"
  echo "                -h  or --host      : Provide host type information. Accepted values: pc (default), vsi, fyre, aws or othervm"
  echo "                help               : Print this usage"
  echo ""
  echo "Examples: ./create_cluster.sh -es=test -f --host=fyre"
  echo "          ./create_cluster.sh --force"
  echo "          ./create_cluster.sh -es=test --force --host=pc"
  echo ""
}

function is_root(){
  if [[ $EUID -ne 0 ]]; then
    echo "Create cluster script (./create_cluster.sh) must be run as 'root' user"
    echo "Sudoer may work or may not, depending upon its configuration"
    echo "Suggestion: sudo su -"
    echo "            cd ${PWD}"
    echo "            ./create_cluster.sh ${args[*]}"
    echo ""
    echo "Exiting. Please try again."
    exit 1
  fi
}

function parse_params(){
  LXD_HOST=""
  ICP_ENV_NAME_SHORT=""
  LXD_AUTO_DESTROY_OLD_CLUSTER_COMPONENTS=""

  for i in "${args[@]}"
  do
    case $i in
      -es=*|--env-short=*)
          ICP_ENV_NAME_SHORT=${i#*=}
          shift
          ;;
      -f=*|--force=*)
          LXD_AUTO_DESTROY_OLD_CLUSTER_COMPONENTS="${i#*=}"
          shift
          ;;
      -h=*|--host=*)
          LXD_HOST="${i#*=}"
          shift
          ;;
      help)
          help
          exit
          shift
          ;;
      *)
          echo "Unknown option passed - ${i#*=}"
          help
          exit -1
          ;;
    esac
  done

  if [[ ! -z "${LXD_HOST}" ]]; then
      sed -i "s|LXD_HOST.*|LXD_HOST=${LXD_HOST}|g"                                                                       ${INSTALL_PROPERITES}
  fi
  if [[ ! -z "${ICP_ENV_NAME_SHORT}" ]]; then
      sed -i "s|ICP_ENV_NAME_SHORT.*|ICP_ENV_NAME_SHORT=${ICP_ENV_NAME_SHORT}|g"                                                   ${INSTALL_PROPERITES}
  fi
  if [[ ! -z "${LXD_AUTO_DESTROY_OLD_CLUSTER_COMPONENTS}" ]]; then
      sed -i "s|LXD_AUTO_DESTROY_OLD_CLUSTER_COMPONENTS.*|LXD_AUTO_DESTROY_OLD_CLUSTER_COMPONENTS=${LXD_AUTO_DESTROY_OLD_CLUSTER_COMPONENTS}|g"         ${INSTALL_PROPERITES}
  fi


}

function install() {
  if [[ -f "./cluster.properties" ]]; then
    echo "## This file is auto-generated ##" > cluster.properties
  fi
  source ./cli-setup/install-clis.sh
  source ./lxd-setup/setup-lxd.sh
  source ./icp-setup/setup-icp.sh
}

is_root
read_properties
parse_params
install
