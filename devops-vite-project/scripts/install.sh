#!/bin/bash
echo "Running Install step..."
cd /home/ec2-user/app
# Pull Docker image from DockerHub (adjust image name)
docker pull akankshyapattnaik/vite-app-image:latest
