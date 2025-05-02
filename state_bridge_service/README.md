# State Bridge Relay Service

This service relays state between Starknet and other blockchains.

## Docker Setup

### Building the Docker image

To build the Docker image manually:

```bash
docker build -t state-bridge-relay .
```

### Running with Docker Compose

The easiest way to run the service is with Docker Compose:

```bash
docker-compose up -d
```

### Stopping the Service

```bash
docker-compose down
``` 