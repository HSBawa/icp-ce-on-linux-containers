#!/bin/bash
string="$(kubectl get cm registration-json -n kube-system  -o yaml)"
client_id="$(echo "$string"| tee registration.yaml |  grep client_id | awk '{print $2}' | tr '\n' ' ' | tr '"' ' ' | tr ',' ' ' | xargs)"
client_secret="$(echo "$string"| tee registration.yaml |  grep "client_secret" | awk '{print $2}' | tr '\n' ' '| tr '"' ' ' | tr ',' ' ' | xargs)"

echo ""
echo "Client ID: $client_id"
echo "Client Secret: $client_secret"
echo ""
TEMPLATE_FILE="/opt/icp-3.1.0-ce/cluster/cfc-components/platform-oidc-registration.json.orig.tmpl"
NEW_FILE="/opt/icp-3.1.0-ce/cluster/cfc-components/platform-oidc-registration.json"

cp   $TEMPLATE_FILE $NEW_FILE

sed -i 's/@@CLIENT_ID@@/'"$client_id"'/g' $NEW_FILE
sed -i 's/@@CLIENT_SECRET@@/'"$client_secret"'/g' $NEW_FILE

OAUTH2_CLIENT_REGISTRATION_SECRET=$(kubectl -n kube-system get secret platform-oidc-credentials -o yaml | grep OAUTH2_CLIENT_REGISTRATION_SECRET | awk '{ print $2}' | base64 --decode)

WLP_CLIENT_ID=$(kubectl -n kube-system get secret platform-oidc-credentials -o yaml | grep WLP_CLIENT_ID | awk '{ print $2}' | base64 --decode)

FIP=10.50.50.101
curl -kvv -X PUT -u oauthadmin:$OAUTH2_CLIENT_REGISTRATION_SECRET -H "Content-Type: application/json" -d @$NEW_FILE https://$FIP:9443/oidc/endpoint/OP/registration/$WLP_CLIENT_ID
