#!/bin/bash

echo "------------------------------"
echo "Starting Vite app deployment"
echo "------------------------------"

# Ensure script runs from the app root (assumes /var/www/html is where files are copied)
cd /var/www/html/devops-vite-project || exit 1

# Install Node.js (LTS version) and npm
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Install dependencies and build the Vite app
echo "Installing npm dependencies..."
npm install

echo "Building Vite app..."
npm run build

# Install and configure Nginx
echo "Installing and starting Nginx..."
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Clean the default web root
sudo rm -rf /var/www/html/*

# Move built files to Nginx web root
sudo cp -r dist/* /var/www/html/

# Set correct permissions
sudo chown -R nginx:nginx /var/www/html
sudo chmod -R 755 /var/www/html

# Restart Nginx to apply changes
sudo systemctl restart nginx

echo "✅ Deployment complete. Visit your EC2 public IP to view the Vite app."
