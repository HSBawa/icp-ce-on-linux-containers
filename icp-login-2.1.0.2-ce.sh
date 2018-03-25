##Contents of this file will be replaced on next successful install
## Default values will be replaced with values from terraform variables (if changed)
# Run following command once and only if ICP plugin is not installed for IBM Cloud CLI
bx plugin install icp-linux-amd64
# Validate ICP CLI plugin install
bx plugin show icp
# Login to ICP CE
bx pr login -a https://10.50.50.201:8443 -u admin -p admin_0000 -c id-devicpcluster-account --skip-ssl-validation
# Cluster config 
bx pr cluster-config devicpcluster
#sudo bx pr cluster-config devicpcluster
# Validate kubectl is working
kubectl get nodes
# Information about clusters
bx pr clusters
# Get cluster specific info
bx pr cluster-get devicpcluster
