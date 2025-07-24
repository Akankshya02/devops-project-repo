#!/bin/bash
echo "Running Install step..."
cd /home/ec2-user/app
# Pull Docker image from DockerHub (adjust image name)
docker pull yourdockerhubusername/vite-app-image:latest
