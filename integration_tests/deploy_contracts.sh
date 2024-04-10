#!/bin/bash

# Change directory to solidity
cd solidity

# Copies the example of anvil configuration file into .env
# that is loaded by foundry automatically.
cp anvil.env .env

# Ensure all variables are exported for the use of forge commands.
source .env

# Deploy contract on Anvil chain
forge script script/LocalTesting.s.sol:LocalSetup --broadcast --rpc-url http://anvil:8545 || { echo "Failed to deploy contract on Anvil chain"; exit 1; }

cd ../cairo

# To ensure starkli env variables are setup correctly.
source katana.env

# Sleep for 60 Seconds waiting to run katana
sleep 60s

# Building the scarb project
scarb build

# Declaring contract using starkli
output=$(starkli declare ./target/dev/messaging_tuto_contract_msg.contract_class.json --keystore-password "") || { echo "Failed to declare contract using starkli"; exit 1; }

# Deploying contract using starkli
starkli deploy $output \
    --salt 0x1234 \
    --keystore-password "" || { echo "Failed to deploy contract using starkli"; exit 1; }

echo "Script completed successfully."

# Run another script after the completion of this script
bash ../test_messaging.sh