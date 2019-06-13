#!/bin/bash

INSTALL_PROPERTIES="./install.properties"
CLUSTER_PROPERTIES="./cluster.properties"
WORKING_DIR="./icp-setup/k8s/istio"
IBM_CHART_SITE_URL="https://raw.githubusercontent.com/IBM/charts/master/repo/stable"
ISTIO_CHART_FILE_NAME="ibm-istio-1.1.0.tgz"
CHART_DIR="ibm-istio"
HELM_RELEASE_NAME="istio"
INSTALL_WITH_SIDECAR=y
GRAPHANA_SECRET_TMPL_YAML="${WORKING_DIR}/tmpl/graphana-secret.yaml.tmpl"
GRAPHANA_SECRET_YAML="${WORKING_DIR}/yamls/graphana-secret.yaml"
KIALI_SECRET_TMPL_YAML="${WORKING_DIR}/tmpl/kiali-secret.yaml.tmpl"
KIALI_SECRET_YAML="${WORKING_DIR}/yamls/kiali-secret.yaml"
POD_SECURITY_POLICY_YAML="${WORKING_DIR}/yamls/pod-security-policy.yaml"

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

function download_chart(){
  echo "curl -f -o ${WORKING_DIR}/${ISTIO_CHART_FILE_NAME} ${IBM_CHART_SITE_URL}/${ISTIO_CHART_FILE_NAME}"
  curl -f -o ${WORKING_DIR}/${ISTIO_CHART_FILE_NAME} ${IBM_CHART_SITE_URL}/${ISTIO_CHART_FILE_NAME}
  tar -xvzf ${WORKING_DIR}/${ISTIO_CHART_FILE_NAME} -C ${WORKING_DIR}
}

function initialize_secrets(){
  ISTIO_GRAPHANA_USERNAME=$(echo -n "${ISTIO_GRAPHANA_USERNAME}" | base64)
  ISTIO_GRAPHANA_PASSPHRASE=$(echo -n "${ISTIO_GRAPHANA_PASSPHRASE}" | base64)
  sed -e 's|@@ISTIO_NAMESPACE@@|'"${ISTIO_NAMESPACE}"'|g' \
      -e 's|@@ISTIO_GRAPHANA_USERNAME@@|'"${ISTIO_GRAPHANA_USERNAME}"'|g' \
      -e 's|@@ISTIO_GRAPHANA_PASSPHRASE@@|'"${ISTIO_GRAPHANA_PASSPHRASE}"'|g' < ${GRAPHANA_SECRET_TMPL_YAML} > ${GRAPHANA_SECRET_YAML}
  ISTIO_KIALI_USERNAME=$(echo -n "${ISTIO_KIALI_USERNAME}" | base64)
  ISTIO_KIALI_PASSPHRASE=$(echo -n "${ISTIO_KIALI_PASSPHRASE}" | base64)
  sed -e 's|@@ISTIO_NAMESPACE@@|'"${ISTIO_NAMESPACE}"'|g' \
      -e 's|@@ISTIO_KIALI_USERNAME@@|'"${ISTIO_KIALI_USERNAME}"'|g' \
      -e 's|@@ISTIO_KIALI_PASSPHRASE@@|'"${ISTIO_KIALI_PASSPHRASE}"'|g' < ${KIALI_SECRET_TMPL_YAML} > ${KIALI_SECRET_YAML}
}

function install_istio(){
  kubectl create ns ${ISTIO_NAMESPACE}
  kubectl apply -f ${POD_SECURITY_POLICY_YAML} -n ${ISTIO_NAMESPACE}
  kubectl apply -f ${GRAPHANA_SECRET_YAML} -n ${ISTIO_NAMESPACE}
  kubectl apply -f ${KIALI_SECRET_YAML} -n ${ISTIO_NAMESPACE}
  if [[ "$1" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo "Installing istio with sidecar"
    helm install ${WORKING_DIR}/${CHART_DIR} --name ${HELM_RELEASE_NAME}  --namespace ${ISTIO_NAMESPACE} --tls
  else
    echo "Installing istio without sidecar"
    helm install ${WORKING_DIR}/${CHART_DIR} --name ${HELM_RELEASE_NAME}  --namespace ${ISTIO_NAMESPACE} --set sidecarInjectorWebhook.enabled=false --tls
  fi
}

function uninstall_istio(){
  helm delete ${HELM_RELEASE_NAME}
}

function post_install_instructions(){
    echo "
Thank you for installing ibm-istio.
Your release is named istio.
To get started running application with Istio, execute the following steps:
  1. Label namespace that application object will be deployed to by the following command (take default namespace as an example)
     $ kubectl label namespace default istio-injection=enabled
     $ kubectl get namespace -L istio-injection
  2. Deploy your applications
     $ kubectl apply -f <your-application>.yaml
For more information on running Istio, visit: https://istio.io/"
}

function install_uninstall(){
  if [[ "$1" == "install" ]]; then
    echo "Installing istio ..."
    download_chart
    initialize_secrets
    install_istio ${INSTALL_WITH_SIDECAR}
    post_install_instructions
  elif [[ "$1" == "uninstall" ]]; then
    echo "Uninstalling istio ..."
    #uninstall_istio
  else
    echo "Valid command options are (install|uninstall)"
    echo "istio-setup install"
    echo "istio-setup uninstall"
  fi
}

read_properties
install_uninstall $1
