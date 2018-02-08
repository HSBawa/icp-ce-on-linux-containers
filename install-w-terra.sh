#!/bin/bash
terraform init
terraform plan -out=plan/icp-on-lxc-plan.txt
terraform apply plan/icp-on-lxc-plan.txt
