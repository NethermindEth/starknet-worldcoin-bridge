#!/bin/bash

# Function to format container details
format_container_details() {
    echo "Container: $1"
    echo "Created: $2"
    echo "Command: $3"
    echo "Ports: $4"
    echo "Exit code: $5"
    echo "-------------------------------------"
}

# List exited containers with their exit code, created date, command, and ports
exited_containers=$(docker ps -a --filter status=exited --format "{{.Names}}|{{.CreatedAt}}|{{.Command}}|{{.Ports}}|{{.Status}}")

# Iterate over exited containers
while IFS='|' read -r name created command ports status; do
    format_container_details "$name" "$created" "$command" "$ports" "Exited ($status)"
done <<< "$exited_containers"

# List running containers with their created date, command, and ports
running_containers=$(docker ps --format "{{.Names}}|{{.CreatedAt}}|{{.Command}}|{{.Ports}}")

# Iterate over running containers
while IFS='|' read -r name created command ports; do
    format_container_details "$name" "$created" "$command" "$ports" "Running"
done <<< "$running_containers"
