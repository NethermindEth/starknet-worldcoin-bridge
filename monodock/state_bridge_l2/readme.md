# Starknet State Bridge Cairo Contracts

This contracts will set up a state bridge between Ethereum and Starknet.


## Requirements

Please before start, install:
-	[scarb](https://docs.swmansion.com/scarb/download.html#requirements) to build cairo contracts.
-   [starkli](https://book.starkli.rs/installation) to interact with Katana.
-   [katana](https://www.dojoengine.org/en/) to install Katana, that belongs to dojo.
- 	[foundry](https://book.getfoundry.sh/getting-started/installation) to interact with Anvil.

Please check the versions, before starting:
- scarb [2.5.4]
- starkli [0.1.20]
- katana [0.6.0]
- forge [0.2.0]

To install submodules run below command:
```bash
git submodule update --init --recursive
```

## Setup Starknet contracts

To setup Starknet contract, please follow those steps:
1. Update katana on the 0.6.0 version to match starkli compatible version (temporary fix due to RPC incompatibility):
   ```bash
   starkliup -v 0.1.20
   dojoup -v 0.6.0
   ```
or you can run docker-compose up which will run containerised Anvil & Katana chains

2. Then open a terminal and starts katana by passing the messaging configuration where Anvil contract address and account keys are setup:
   ```bash
   katana --messaging config.json
   ```

   Katana will now poll anvil logs exactly as the Starknet sequencer does on the `StarknetMessaging` contract on ethereum.

3. In a new terminal, go into cairo folder and build contracts:
   ```bash
   cd monodock/state_bridge_l2
   
   # To ensure starkli env variables are setup correctly.
   source katana.env

   scarb build
   ```
4. Try to use starkli to declare and deploy the contracts on Katana
 	```bash
	starkli declare ./target/dev/world_id_state_bridge_StarkWorldID.contract_class.json
   ```
But is shows the error
```bash
 starkli declare ./target/dev/world_id_state_bridge_StarkWorldID.contract_class.json --compiler-version 2.1.0
Enter keystore password: 
Declaring Cairo 1 class: 0x03eaab5a0bfa9b93fa9fb5f4130119dea4b33d8803039a363546d30118a7a9c9
Compiling Sierra class to CASM with compiler version 2.1.0...
Error: error from the program registry

```
Found the following github issue for the error we are facing:
https://github.com/OpenZeppelin/cairo-contracts/issues/859

5. Once the issue is resolved try to deploy the contracts on Katana
```bash
starkli deploy <Contract Hash> \
       --salt 0x1234 \
       --keystore-password ""
```