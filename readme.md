<div align="center">
  <h1>Worldcoin <=> Starknet Bridge</h1>
</div>

## About
Contains all smart contracts for L1 and L2.

Key Details:
- Propogate the root of the identity merkle tree from L1 to L2 using Starknet's Cross Messenger.
- Built-in Groth16 verifier, easy verification using [Garaga](https://github.com/keep-starknet-strange/garaga)
- Local bridge setup testing

## Local Testing Setup

### Setting up Local Development 
1. In new terminal, run a local anvil node
```anvil```
2. In new terminal, run a local katana node
```
cd starknet-worldcoin-bridge/state_bridge_l2
katana –messaging config.json
```
3. In new terminal, then run setup script
```
cd starknet-worldcoin-bridge/state_bridge_l2
./setup.sh
```
4. In new terminal, source environment variables, run setup script
```
cd starknet-worldcoin-bridge/state_bridge_l1
cp anvil.env .env
source .env
forge script script/SetupContracts.s.sol:LocalSetup --broadcast --rpc-url ${ETH_RPC_URL}
```

### Setting up the Relay 
1. In new terminal, run test script that launches relay
```
cd starknet-worldcoin-bridge/monodock/state_bridge_service
cargo test
```

