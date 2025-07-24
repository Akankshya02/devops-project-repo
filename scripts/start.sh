#!/bin/bash
echo "Starting application..."
# Stop and remove existing container if any
docker stop vite-container || true
docker rm vite-container || true

# Run new container
docker run -d --name vite-container -p 80:80 yourdockerhubusername/vite-app-image:latest
