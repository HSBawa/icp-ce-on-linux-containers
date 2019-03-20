#!/bin/bash
echo "This is example script. Update comamnd parameters, in script, as per your needs."
openssl genrsa -out icp-router.key 4096
openssl req -new -key icp-router.key -out icp-router.csr -subj "/CN=mycluster.icp"
