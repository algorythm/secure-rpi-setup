#!/usr/bin/env bash

source print.sh

bot "Installing docker!"
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh

running "Adding user $USER (you) to the docker group"
sudo groupadd docker
sudo adduser $USER docker
ok

bot "Testing docker"
docker run hello-world

running "Cleaning up all docker containers and images"
sudo docker ps --all -q | xargs sudo docker rm
sudo docker images -q | xargs sudo docker rmi
ok

bot "Installing docker-compose v1.22"
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
ok

bot "Docker is now installed!"
