FROM rust:1.71-slim-bullseye

WORKDIR /app

# Install any additional dependencies that might be needed
RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy the entire project directory
COPY . .

# Set the working directory to where the code is
WORKDIR /app

# Build the application
RUN cargo build --release --bin state_bridge_relay

# Create a directory for any configuration files
RUN mkdir -p /app/config

# Run the binary
CMD ["./target/release/state_bridge_relay"] 