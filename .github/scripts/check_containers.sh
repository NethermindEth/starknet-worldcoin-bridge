#!/bin/bash

# Function to format container details
format_container_details() {
    echo "Container: $1"
    echo "Created: $2"
    echo "Command: $3"
    echo "Ports: $4"
    echo "Health: $5"
    echo "Exit code: $6"
    echo "-------------------------------------"
}

# Function to fetch the latest block number from Anvil chain
fetch_latest_block_number() {
    block_info=$(wget -qO- --header="Content-type: application/json" --post-data='{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' http://localhost:8545)
    block_number_hex=$(echo "$block_info" | jq -r '.result.number')
    # Convert hex to decimal
    block_number_dec=$(($block_number_hex))
    echo "$block_number_dec"
}

# Check for block increase for 3 consecutive steps
check_block_increase() {
    previous_block=0
    for ((i=1; i<=3; i++)); do
        echo "Checking block increase: Step $i"
        current_block=$(fetch_latest_block_number)
        echo "Latest block: $current_block"
        if [[ $current_block -gt $previous_block ]]; then
            echo "Anvil Chain Block number is increasing."
            previous_block=$current_block
        else
            echo "Anvil Chain Block number is not increasing."
            exit 1
        fi
        sleep 5 # Wait for some time before next check
    done
}

# Function to fetch container health status
fetch_container_health_status() {
    health_status=$(docker inspect --format='{{json .State.Health}}' "$1")
    echo "$health_status"
}

# List exited containers with their exit code, created date, command, ports, and health status
exited_containers=$(docker ps -a --filter status=exited --format "{{.Names}}|{{.CreatedAt}}|{{.Command}}|{{.Ports}}|{{.Status}}")

# Iterate over exited containers
while IFS='|' read -r name created command ports status; do
    health=$(fetch_container_health_status "$name")
    format_container_details "$name" "$created" "$command" "$ports" "$health" "Exited ($status)"
done <<< "$exited_containers"

# List running containers with their created date, command, ports, and health status
running_containers=$(docker ps --format "{{.Names}}|{{.CreatedAt}}|{{.Command}}|{{.Ports}}")

# Iterate over running containers
while IFS='|' read -r name created command ports; do
    health=$(fetch_container_health_status "$name")
    format_container_details "$name" "$created" "$command" "$ports" "$health" "Running"
done <<< "$running_containers"

# Check block increase for 3 consecutive steps
check_block_increase
