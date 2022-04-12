#!/usr/bin/bash

echo "Starting script to install docker & docker-compose"

echo "Update and upgrade" 
sudo apt-get update && sudo apt-get upgrade -y

echo "Install dependencies"
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

echo "Download script from 'https://get.docker.com' for adding the docker repo's and keys and stuff"
curl -sSL https://get.docker.com | sh

echo "Update again and install docker agent and dependencies from newly added docker repo"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
mkdir /home/pi/.docker

echo "Start docker and enable automatic start at boot as a service"
sudo systemctl start docker && sudo systemctl enable docker

echo "Add new group to user"
sudo usermod -aG docker pi
# sudo su - $USER
# groups
echo "Finishing and rebooting"
sudo reboot now
