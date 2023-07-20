#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install -y nginx1
sudo systemctl start nginx
sudo systemctl enable nginx
echo ?Hello World from $(hostname -f)? > /var/www/html/index.html              