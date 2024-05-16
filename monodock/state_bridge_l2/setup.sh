#!/bin/bash
export STARKNET_ACCOUNT=katana-0
export STARKNET_RPC=http://0.0.0.0:5050

# Parameters 
messaging-config="config.json" # Messaging Config
json_file="./target/dev/world_id_state_bridge_StarkWorldID.contract_class.json" # Output of scarb build
compiler_version="2.6.2" # Set the compiler version
l1_address="0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0" # L1 Contract Address of Bridge
tree_depth="30" # Tree Depth
salt="0x1234" # Salt
katana_rpc="http://0.0.0.0:5050" # Local RPC
katana_0="katana-0" # Katana account

# Declare Class Hash 
class_hash=$(starkli declare "$json_file" --compiler-version "$compiler_version")

# Deploy Class Contract
contract_address=$(starkli deploy "$class_hash" "$l1_address" "$tree_depth" --salt "$salt" --rpc "$katana_rpc")

# File path to anvil.env
anvil_env_file="../state_bridge_l1/anvil.env"

# Read the contents of the .env file
env_contents=$(cat "$anvil_env_file")

# Update the value of the target variable in the .env file
updated_contents=$(echo "$env_contents" | sed "s/^STARK_WORLD_ID_ADDRESS=.*/STARK_WORLD_ID_ADDRESS=$contract_address/")

# Write the updated contents back to the .env file
echo "$updated_contents" > "$anvil_env_file"

echo "Updated anvil.env file with address: $contract_address"