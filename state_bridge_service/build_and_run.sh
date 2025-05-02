#!/bin/bash
set -e

echo "Building Docker image..."
docker build -t state-bridge-relay .

echo "Running Docker container..."
docker run -it state-bridge-relay 