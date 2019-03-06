###############################################################################
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################
echo "This program is going to destory all terraform states in next 10 secs. Press Ctrl-C to cancel now."
sleep 10
rm -rf ./.terraform
rm ./terraform.tfstate
rm ./terraform.tfstate.backup
