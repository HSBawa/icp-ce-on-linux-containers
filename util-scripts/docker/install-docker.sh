echo [Installing latest Docker CE]
CURL_INSTALLED="$(which curl)"
if [[ -z "${CURL_INSTALLED}" ]]; then
  echo "curl missing. Install command: sudo apt-get install curl -y"
  exit -1
fi
curl -o /tmp/get-docker.sh -fsSL get.docker.com &> /dev/null
sh /tmp/get-docker.sh &> /dev/null
usermod -aG docker root &> /dev/null
usermod -aG docker ubuntu &> /dev/null
echo "$(docker version)"
echo ""
echo "Done."
