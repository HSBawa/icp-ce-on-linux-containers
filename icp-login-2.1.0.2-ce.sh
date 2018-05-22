## Contents of this file will be replaced on next successful install
## Default values will be replaced with values from terraform variables (if changed)
echo ""
echo "Installing ICP Plugin ..."
bx plugin install icp-linux-amd64 -f
# Validate ICP CLI plugin install
echo ""
bx plugin list
# Login to ICP CE
echo ""
echo -n "Login into ICP with "
bx pr login -a https://10.50.50.201:8443 -u admin -p admin_0000 -c id-devicpcluster-account --skip-ssl-validation
# Cluster config
echo ""
echo -n "ICP Cluster "
bx pr cluster-config devicpcluster
# Validate kubectl is working
echo ""
echo "Getting ICP nodes information  ..."
kubectl get nodes
# Information about clusters
echo ""
echo "Listing clusters ..."
bx pr clusters
# Get cluster specific info
echo ""
bx pr cluster-get devicpcluster
echo ""
