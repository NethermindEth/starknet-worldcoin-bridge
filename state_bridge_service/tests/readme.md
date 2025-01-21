# Deploying the relay for testnet

1. create .env file with these headers:
```
HTTP_TESTNET=FILL_WITH_ETH_RPC_SEPOLIA
TEST_PRIVATE_KEY=FILL_WITH_ETH_SEPOLIA_PRIVATE_KEY
```

2. Run 
```cargo test testnet_relay```