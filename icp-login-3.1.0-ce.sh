##Contents of this file will be replaced on next successful install
## Default values will be replaced with values from terraform variables (if changed)
## Cluster name is : devicpcluster
# Login to ICP CE
sudo cloudctl login -a https://10.50.50.101:8443 -u admin -p admin_0000 -c id-devicpcluster-account -n default  --skip-ssl-validation
sudo cloudctl cm nodes
sudo cloudctl api
sudo cloudctl target
sudo cloudctl config --list
sudo cloudctl catalog repos
sudo cloudctl iam roles
sudo cloudctl iam services
sudo cloudctl iam service-ids
sudo cloudctl pm passwword-rules devicpcluster default
sudo cloudctl catalog charts
