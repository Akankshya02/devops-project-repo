#!/bin/bash

echo "------------------------------"
echo "Starting Vite app deployment"
echo "------------------------------"

# Go to the correct directory (matching appspec.yml)
cd /home/ec2-user/devops-vite-project || exit 1

# Install Node.js and npm
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Install dependencies and build the Vite app
echo "Installing npm dependencies..."
npm install

echo "Building Vite app..."
npm run build

# Install and start Nginx
echo "Installing and starting Nginx..."
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Clean default Nginx directory
sudo rm -rf /var/www/html/*

# Copy built files to Nginx root
sudo cp -r dist/* /var/www/html/

# Fix permissions
sudo chown -R nginx:nginx /var/www/html
sudo chmod -R 755 /var/www/html

# Restart Nginx
sudo systemctl restart nginx

echo "✅ Deployment complete. Visit your EC2 public IP to view the Vite app."
