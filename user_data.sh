#!/bin/bash
yum update -y
yum install -y httpd
echo "<h1>Welcome to BLUE/GREEN App</h1>" > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd
