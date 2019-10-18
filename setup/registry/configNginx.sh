#!/bin/bash

sudo apt update -y
sudo apt install nginx -y
sudo ufw allow 'Nginx Full'

sudo mkdir -p /var/www/registry.algo.fit/html
sudo chown -R $USER:$USER /var/www/registry.algo.fit/html
sudo chmod -R 755 /var/www/registry.algo.fit

cp -r registry.algo.fit/ /var/www/
cp -r sites-available/ /etc/nginx/

cp sites-available/registry.algo.fit /etc/nginx/sites-enabled/
cp nginx.conf /etc/nginx/

sudo nginx -t
sudo systemctl restart nginx
