#!/usr/bin/bash

echo '- Start script to update portainer -'

echo '- Start update -'
sudo apt-get update

echo '- Stopping container -'
docker stop portainer
echo '- Removing container -'
docker rm portainer
echo '- Pulling new image -'
docker pull portainer/portainer-ce:latest
echo '- Spinning up container -'
docker run -d -p 8000:8000 -p 9000:9000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
echo '- Done -'