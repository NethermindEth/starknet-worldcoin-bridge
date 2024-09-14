<div align="center">
  <h1>Worldcoin <=> Starknet Bridge</h1>
</div>

## About
Contains all smart contracts for L1 and L2.

Key Details:
- Propogate the root of the identity merkle tree from L1 to L2 using Starknet's Cross Messenger.
- Built-in Groth16 verifier, easy verification using [Garaga](https://github.com/keep-starknet-strange/garaga)
- Local bridge setup testing

## Setup
1. Deploy the L1 contract using the Address of the (World ID Manager)(https://docs.starknet.io/tools/important-addresses/), a temporary L2 address (ie. 1), and the address of the (Starknet Sequencer - Core Contract)[https://docs.starknet.io/tools/important-addresses/]
2. Take the L1 contract deployed address and use it to deploy the L2 contract along with the fixed tree depth of 30.
3. Take the L2 address and change the L1 contract's L2 address by invoking the "setStarkWorldIDAddress(uint256)" function with the L2 address
4. Bridge is now setup. You can propogate root by sending in eth as value parameter. 

## Local Testing Setup (Deprecated)
* Note: This local setup is deprecated due to bridge version upgrade not being compatible with the katana json rpc version that is used in tandem with starkli

### Setting up Local Development 
1. In new terminal, run a local anvil node
```anvil```
2. In new terminal, run a local katana node
```
cd state_bridge_l2
katana --messaging config.json
```
3. In new terminal, then run setup script
```
cd state_bridge_l2
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

## Disclaimer
Contracts are not yet audited.
