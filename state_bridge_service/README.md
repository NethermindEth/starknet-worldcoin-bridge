
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
docker compose down
```

### To pass in flags (default example):

```bash
docker run state-bridge-relay:latest --network sepolia --fee estimate --verbose
```

## Monitoring Setup

### Accessing Metrics

Once the service is running, metrics are available at:
```
http://localhost:9091/metrics
```

## Development

### Running Locally

1. Copy environment configuration:
```bash
cp example.env .env
# Edit .env with your actual values
```

2. Run the service:
```bash
cargo run --bin state_bridge_relay -- --network sepolia --fee estimate
```

3. View metrics:
```bash
curl http://localhost:9091/metrics
```

### Testing Balance Monitoring

The balance monitoring system will:
- Poll L1 wallet balance every 30 seconds
- Track gas price changes
- Log balance changes and polling duration
- Export metrics for external monitoring
- Maintain historical balance data

### Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Ethereum L1   │◄──►│  State Bridge    │◄──►│   Starknet L2   │
│                 │    │    Service       │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                      ┌──────────────────┐
                      │   Telemetry      │
                      │   - Balance      │
                      │   - Metrics      │
                      │   - History      │
                      └──────────────────┘
                              │
                              ▼
                      ┌──────────────────┐
                      │   Prometheus     │
                      │   Metrics API    │
                      │   :9091/metrics  │
                      └──────────────────┘
```