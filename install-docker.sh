#!/usr/bin/env bash

source print.sh

function pipinstall() {
  if questionY "Do you want to install it"
  then
    if ! [ -x "$(command -v pip3)" ]; then
      echo "Error: pip3 does not exist."
      exit 1
    else
      sudo pip3 install $1
    fi
  else
    exit 1
  fi
}

bot "Installing docker!"
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh

rm get-docker.sh

running "Adding user $USER (you) to the docker group"
sudo groupadd docker
sudo adduser $USER docker
ok

bot "Testing docker"
sudo docker run hello-world

running "Cleaning up all docker containers and images"
sudo docker ps --all -q | xargs sudo docker rm
sudo docker images -q | xargs sudo docker rmi
ok

bot "Installing docker-compose"
if ! [ -x "$(command -v docker-compose)" ]; then
  pipinstall docker-compose
fi
ok

bot "Docker is now installed!"
