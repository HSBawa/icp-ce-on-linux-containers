echo [Installing docker-ce]
curl -o /tmp/get-docker.sh -fsSL get.docker.com &> /dev/null
sh /tmp/get-docker.sh &> /dev/null
usermod -aG docker root &> /dev/null
usermod -aG docker ubuntu &> /dev/null
echo "Done."
echo ""
echo "$(docker version)"
