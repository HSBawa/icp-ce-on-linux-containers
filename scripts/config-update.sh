#!/bin/bash

## source ./scripts/config-update.sh $admin_user $admin_pass $cluster_name $cluster_domain $cluster_CA_domain $cluster_lb_address $proxy_lb_address
echo ""
echo "Input is : $*"
echo ""

admin_user="$1"
admin_pass="$2"
cluster_name="$3"
cluster_domain="$4"
cluster_CA_domain="$5"
cluster_lb_address="$6"
proxy_lb_address="$7"
disabled_management_services="$8"
template_config_file="./cluster/config.yaml.310.tmpl"
config_file="./cluster/config.yaml"
test_config_file="./cluster/config-test.yaml"



function print_input(){
    cp $template_config_file $test_config_file
    echo ">>>>>>>>>>>>>>>[Printing config data : $test_config_file]"
    echo "default_admin_user: $admin_user" | tee -a $test_config_file
    echo "default_admin_password: $admin_pass" | tee -a $test_config_file
    echo "cluster_name: $cluster_name" | tee -a $test_config_file
    echo "cluster_domain: $cluster_domain" | tee -a $test_config_file
    echo "cluster_CA_domain: \"$cluster_CA_domain\"" | tee -a $test_config_file
    echo "cluster_lb_address: $cluster_lb_address" | tee -a $test_config_file
    echo "proxy_lb_address: $proxy_lb_address" | tee -a $test_config_file
    if [[ ! -z $disabled_management_services  ]]; then
        local services=($disabled_management_services)
        echo "management_services:" | tee -a $test_config_file
        for service in ${services[*]}
        do
             echo "   $service: disabled" | tee -a $test_config_file
        done
    fi
    echo ""
}

function update_config(){
    echo ">>>>>>>>>>>>>>>[Update ICP Config YAML : $config_file]"
    cp $template_config_file $config_file
    echo "default_admin_user: $admin_user" | $config_file &> /dev/null
    echo "default_admin_password: $admin_pass" | tee -a $config_file &> /dev/null
    echo "cluster_name: $cluster_name"  | tee -a $config_file &> /dev/null
    echo "cluster_domain: $cluster_domain"  | tee -a $config_file &> /dev/null
    echo "cluster_CA_domain: \"$cluster_CA_domain\""  | tee -a $config_file &> /dev/null
    echo "cluster_lb_address: $cluster_lb_address"  | tee -a $config_file &> /dev/null
    echo "proxy_lb_address: $proxy_lb_address"  | tee -a $config_file &> /dev/null
    if [[ ! -z $disabled_management_services  ]]; then
        local services=($disabled_management_services)
        echo "management_services:" | tee -a $config_file &> /dev/null
        for service in ${services[*]}
        do
             echo "   $service: disabled" | tee -a $config_file &> /dev/null
        done
    fi
    echo ""
}

#print_input
update_config
