#!/bin/bash

sudo apt update
sudo apt install nginx
sudo ufw enable
sudo ufw allow 'Nginx Full’

sudo mkdir -p /var/www/registry.algo.fit/html
sudo chown -R $USER:$USER /var/www/registry.algo.fit/html
sudo chmod -R 755 /var/www/registry.algo.fit

cp -r registry.algo.fit/ /var/www/
cp -r sites-available/ etc/nginx/

sudo ln -s /etc/nginx/sites-available/registry.algo.fit /etc/nginx/sites-enabled/

sudo nginx -t
sudo systemctl restart nginx

