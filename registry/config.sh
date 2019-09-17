#!/bin/bash
bash configNginx.sh
sudo apt install docker -y
snap install docker -y
sudo apt install apache2-utils -y
cp -r docker-registry ~ 
cd ~/docker-registry 
mkdir data
sudo service nginx restart
docker-compose up -d