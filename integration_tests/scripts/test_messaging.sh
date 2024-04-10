#!/bin/bash

broadcast_message() {
    # Change directory to solidity
    cd ../solidity

    # Copies the example of anvil configuration file into .env
    # that is loaded by foundry automatically.
    cp anvil.env .env

    # Ensure all variables are exported for the use of forge commands.
    source .env

    # Command to broadcast message to katana
    forge script script/SendMessage.s.sol:Value --broadcast --rpc-url http://localhost:8545

    # Sleep 10s to get exact results
    sleep 10s
}

get_block_info() {
    # Command 1: Get block hash and number
    block_info=$(curl http://localhost:5050 \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"starknet_blockHashAndNumber","params": [""],"id":1}')

    # Extract block hash from the response
    block_hash=$(echo "$block_info" | jq -r '.result.block_hash')
}

get_transaction_info() {
    # Command 2: Get block details with transaction hashes
    block_details=$(curl http://localhost:5050 \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"starknet_getBlockWithTxHashes","params": [{"block_hash":"'"$block_hash"'"}],"id":1}')

    # Extract transaction hash from the response
    transaction_hash=$(echo "$block_details" | jq -r '.result.transactions[0]')

    # Command 3: Get transaction details
    transaction_details=$(curl http://localhost:5050 \
        -X POST \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"starknet_getTransactionByHash","params":["'"$transaction_hash"'"],"id":1}')
}

print_results() {
    # Extract calldata from the response
    calldata=$(echo "$transaction_details" | jq -r '.result.calldata[1]')

    # Convert calldata from hexadecimal to decimal
    calldata_decimal=$(printf "%d" "$calldata")

    echo "Calldata in decimal: $calldata_decimal"

    # Check if calldata_decimal equals 123
    if [ "$calldata_decimal" -eq 123 ]; then
        echo "Message passing is working successfully."
    fi

    # Print block_info
    echo "Block Hash:"
    echo "$block_hash"

    # Print transaction_hash
    echo "Transaction Hash:"
    echo "$transaction_hash"

    # Print transaction_hash
    echo "Transaction Details:"
    echo "$transaction_details"
}

# Main function
main() {
    broadcast_message
    get_block_info
    get_transaction_info
    print_results
}

# Call the main function
main
