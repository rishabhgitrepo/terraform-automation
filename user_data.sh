#! /bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
sudo echo '</h> Welcome to Terraform Project</h>' | sudo tee /var/www/html/index.html
