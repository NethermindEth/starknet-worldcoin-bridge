#!/bin/bash

# Change directory to solidity
cd solidity || { echo "Failed to change directory to solidity"; exit 1; }

# Copies the example of anvil configuration file into .env
# that is loaded by foundry automatically.
cp anvil.env .env

# Ensure all variables are exported for the use of forge commands.
source .env

# Deploy contract on Anvil chain
forge script script/LocalTesting.s.sol:LocalSetup --broadcast --rpc-url http://anvil:8545

cd ../cairo

# To ensure starkli env variables are setup correctly.
source katana.env

scarb build

starkli declare ./target/dev/messaging_tuto_contract_msg.contract_class.json --keystore-password ""

starkli deploy 0x02d6b666ade3a9ee98430d565830604b90954499c590fa05a9844bdf4d3a574b \
    --salt 0x1234 \
    --keystore-password ""

echo "Script completed successfully."