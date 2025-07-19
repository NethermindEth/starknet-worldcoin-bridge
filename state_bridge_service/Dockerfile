# Building image
FROM rust:1.86-alpine AS builder

# Install any additional dependencies that might be needed
RUN apk add                   \
        build-base            \
        pkgconfig             \
        openssl-dev           \
        openssl-libs-static   \
        ca-certificates       \
        && rm -rf /var/lib/apt/lists/*

ENV OPENSSL_STATIC=1

WORKDIR /app

# Copy the entire project directory
COPY Cargo.lock Cargo.lock
COPY Cargo.toml Cargo.toml
COPY ./state_bridge_service ./state_bridge_service

# Create a directory for any configuration files
RUN mkdir -p /app/config

# Run the binary
RUN cargo build --release --bin state_bridge_relay 

# Run Image
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/state_bridge_relay /usr/local/bin/state_bridge_relay

RUN useradd -m appuser
USER appuser

# Expose the Prometheus metrics port
EXPOSE 9091

ENTRYPOINT ["/usr/local/bin/state_bridge_relay"]
CMD ["--network" ,"sepolia", "--fee", "estimate"] 