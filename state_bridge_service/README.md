# State Bridge Relay Service

This service relays state between Starknet and other blockchains.

## Docker Setup

### Building the Docker image

To build the Docker image manually:

```bash
docker build
```

### Running with Docker Compose

To run the docker image:

```bash
docker compose up
``` 

### Build and run:

```bash
docker compose up -d 
```

### Shutdown docker image:

```bash
docker down
```

### To pass in flags (default example):

```bash
docker run state-bridge-relay:latest --network sepolia --fee estimate --verbose
```