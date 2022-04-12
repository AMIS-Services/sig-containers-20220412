#!/usr/bin/bash

set -e

echo "Starting script to install docker & docker-compose"

echo "Checking if user pi is in group docker"
username=pi
if getent group docker | grep -q "\b${username}\b"; then
    echo true
else
    echo false
	exit
fi

echo "Install docker-compose & dependencies"
sudo apt-get install -y libffi-dev libssl-dev
sudo apt install -y python3-dev
sudo apt-get install -y python3 python3-pip
sudo pip3 install docker-compose

echo "Check if docker is up and running by returning the version"
docker version
docker ps

echo "Deploying portainer"
docker volume create portainer_data
docker pull portainer/portainer-ce:latest
docker run -d -p 8000:8000 -p 9000:9000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

echo "If you came this far without issue, congrats!"
echo "You can now start deploying containers"
