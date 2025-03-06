#!/bin/bash
echo "Installing dependencies..."
yum update -y && yum install -y git nodejs npm
echo "Cloning repository..."
git clone https://github.com/k-27feed/second-brain-api.git /opt/second-brain-api
echo "Starting application..."
cd /opt/second-brain-api && npm install && npm run build && npm start
