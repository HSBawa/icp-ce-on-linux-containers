#!/bin/bash
###############################################################################
## This programs initiates ICP on CE installation process using terraform
##   a) Create one of the following cluster of LXD nodes for IBM Cloud Private - Community Edition (ICP-CE)
##       1) 1 Master - n Worker nodes architecture
##       2) 1 Master, 1 Proxy, 1 Management and n Worker node(s) architecture
##   b) Install ICP-CE installation on cluster of LXD nodes
## @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
###############################################################################

minimal="false"

##### TEMP ONLY FOR TESTING
function terra_clean(){
    echo "Deleting terraform states"
    rm -rf .terraform
    rm terraform.tfstate
    rm terraform.tfstate.backup
    rm plan/*
}


function start_banner(){
     echo ""
     echo ""
     echo "+-+-+-+-+-+-+-+ +-+-+ +-+-+-+ +-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+"
     echo "|W|e|l|c|o|m|e| |t|o| |I|C|P| |o|n| |L|i|n|u|x| |C|o|n|t|a|i|n|e|r|s|"
     echo "---------------------------------------------------------------------"
     echo "|           |H|a|r|i|m|o|h|a|n| |S| |B|a|w|a|                       |"
     echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
     echo ""
     echo ""
}



function select_install_option(){
    echo "(F)ull install: Master, Proxy, Management and Worker Nodes."
    echo "(M)inimal install: Master and Worker Nodes."
    echo -n "Selected install type? [F]/M : "
    read install_type

    shopt -s nocasematch
    if [[ "$install_type" == "F"  ]]; then
       echo "User selected Full install."
       minimal="false"
   elif [[ "$install_type" == "M"  ]]; then
       echo "User selected Minimal install."
       minimal="true"
    else
       echo "Invalid selection. Please try again. Exiting."
       exit -1;
    fi
    shopt -u nocasematch

}

function start_install(){
    mkdir -p /media/lxcshare &> /dev/null
    chmod +x ./scripts/*.sh
    cp main.tf.tmpl main.tf &> /dev/null
    if [[ "$minimal" == "false"  ]]; then
        ## For full install
        cat proxy-mgmt.tf.tmpl | tee -a main.tf   &> /dev/null
    fi
    ## Start installation
    terraform init
    if [[ "$minimal" == "false"  ]]; then
        echo "Executing terraform: terraform plan -var 'cluster={minimal=false}' -out=plan/icp-on-lxc-plan.txt"
        terraform plan -var 'cluster={minimal=false}' -out=plan/icp-on-lxc-plan.txt
    else
        echo "Executing terraform: terraform plan -out=plan/icp-on-lxc-plan.txt"
        terraform plan -out=plan/icp-on-lxc-plan.txt
    fi
    terraform apply plan/icp-on-lxc-plan.txt

}

start_banner
terra_clean
select_install_option
start_install
