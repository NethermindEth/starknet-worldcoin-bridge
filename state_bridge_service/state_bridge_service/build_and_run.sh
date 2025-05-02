#!/bin/bash
set -e

echo "Building Docker image..."
cd /home/dev/starknet-worldcoin-bridge/state_bridge_service/state_bridge_service
docker build -t state-bridge-relay .

echo "Running Docker container..."
docker run -it state-bridge-relay 