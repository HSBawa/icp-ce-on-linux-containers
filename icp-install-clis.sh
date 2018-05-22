## Contents of this file will be replaced on next successful install
## Default values will be replaced with values from terraform variables (if changed)
echo -n "Downloading lastet kubectl ... "
curl -sq -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && sudo mv kubectl /usr/local/bin && sudo chmod +x /usr/local/bin/kubectl
echo "Done"
echo "Install location: $(which kubectl)"
echo "$(/usr/local/bin/kubectl version --client=true --short=true)"
echo ""

# download 'helm cli' from your local ICP and install
echo -n "Downloading lastet ICP Helm  ... "
wget -nv -q https://10.50.50.201:8443/helm-api/cli/linux-amd64/helm --no-check-certificate
sudo mv helm /usr/local/bin
sudo chmod +x /usr/local/bin/helm
echo "Done"
echo "Install location: $(which helm)"
echo "$(helm version --tls)"
helm init --client-only
echo ""
echo -n "Downloading lastest IBM Cloud CLI ... "
curl -sq -fsSL https://clis.ng.bluemix.net/install/linux | bash &> /dev/null
echo "Done"
echo "Install location: $(which bx)"
echo "$(bx -v)"
echo ""
if [ -f $PWD/icp-linux-amd64 ]; then
    echo -n "ICP Plugin exists. Will overwrite. "
fi
echo -n "Downloading latest ICP Plugin ... "
wget -nv -q https://10.50.50.201:8443/api/cli/icp-linux-amd64 --no-check-certificate
echo "Done"
echo $(ls -al icp-linux-amd64)
echo ""
