#/bin/bash

## configure_docker_cli.sh dev

env="dev"
crt_dir="/etc/docker/certs.d/${env}icpcluster.icp:8500"
icp_ca_domain="${env}icpcluster.icp:8500"
set_environment(){
  if [[  -z "$1" ]]; then
    echo "WARNING!!! Empty environment passed. Using '$env' as default"
  else 
    env=$1
  fi
  icp_ca_domain="${env}icpcluster.icp:8500"
  crt_dir="/etc/docker/certs.d/${icp_ca_domain}"
}

auth_for_docker_cli(){
   rm -rf ${crt_dir}
   mkdir -p ${crt_dir}
   lxc file pull  ${env}-master-0${crt_dir}/ca.crt ${crt_dir}/ca.crt
   systemctl restart docker
}

echo ""
echo ">>>>>>>>>>>>>>>>>>> Setting up authentication for host Docker CLI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
set_environment $1
echo "Enviroment : $env"
auth_for_docker_cli
echo "Listing crt in ${crt_dir}"
echo "$(ls ${crt_dir})"
echo ""
