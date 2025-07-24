#!/bin/bash
echo "Running BeforeInstall step..."
cd /home/ec2-user
rm -rf app
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

