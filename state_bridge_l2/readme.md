# Starknet State Bridge Cairo Contracts

This contracts will set up a state bridge between Ethereum and Starknet.


## Requirements

Please before start, install:
-	[scarb](https://docs.swmansion.com/scarb/download.html#requirements) to build cairo contracts.
-   [starkli](https://book.starkli.rs/installation) to interact with Katana.
-   [katana](https://www.dojoengine.org/en/) to install Katana, that belongs to dojo.
- 	[foundry](https://book.getfoundry.sh/getting-started/installation) to interact with Anvil.

Please check the versions, before starting:
<<<<<<< HEAD
- scarb [2.5.4]
- starkli [0.1.20]
- katana [0.6.0]
=======
- scarb [2.6.3]
- starkli [0.2.9]
- katana [0.7.0-alpha.1]
>>>>>>> fb83e7ee1e3430129911d957d5e95e554d4ab100
- forge [0.2.0]

To install submodules run below command:
```bash
git submodule update --init --recursive
```

## Setup Starknet contracts

<<<<<<< HEAD
To setup Starknet contract, please follow those steps:
1. Update katana on the 0.6.0 version to match starkli compatible version (temporary fix due to RPC incompatibility):
   ```bash
   starkliup -v 0.1.20
   dojoup -v 0.6.0
=======
To setup Starknet contract, please follow this steps:
1. Update katana on the 0.6.0 version to match starkli compatible version (temporary fix due to RPC incompatibility):
   ```bash
   starkliup -v 0.2.9
   dojoup -v 0.7.0-alpha.1
>>>>>>> fb83e7ee1e3430129911d957d5e95e554d4ab100
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
<<<<<<< HEAD
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
=======
	tarkli declare ./target/dev/world_id_state_bridge_StarkWorldID.contract_class.json --compiler-version 2.6.2
   ```
   Output:
   ```bash
   Declaring Cairo 1 class: 0x029c070905034e8b8af897c3590930bac4fb6065e7a74c279c1ae266032f4b74
   Compiling Sierra class to CASM with compiler version 2.6.2...
   CASM class hash: 0x047693d103b6de802a422515a4f296fb02c55862613596f8d7d74771c951cabc
   Contract declaration transaction: 0x031a98aade4c697edcc46a5ce6937aa2b1f98441ebd217b6742b8b79f8386d17
   Class hash declared:
   0x029c070905034e8b8af897c3590930bac4fb6065e7a74c279c1ae266032f4b74
   ```

5. Once the contract is declared try to deploy the contracts on Katana
   Command: starkli deploy [contract hash] [L1 Contract Address] [20]
   ```bash
   starkli deploy 0x029c070905034e8b8af897c3590930bac4fb6065e7a74c279c1ae266032f4b74  0xf15689636571dba322b48E9EC9bA6cFB3DF818e1 20
   ```
   Output:
   ```bash
   Deploying class 0x029c070905034e8b8af897c3590930bac4fb6065e7a74c279c1ae266032f4b74 with salt 0x030d7be7360dde808a43a8cf5f217d9dfa1cebde682db73d9a68978bda0218db...
   The contract will be deployed at address 0x05e925238c7339f706e0908ef7424c3dc8369bace26da2fa7f2468a634f69070
   Contract deployment transaction: 0x0730f154a5fef18d9e65a1bf911555c836ee290cc2411608e1f7c9ccc105e8ee
   Contract deployed:
   0x05e925238c7339f706e0908ef7424c3dc8369bace26da2fa7f2468a634f69070

   ```
>>>>>>> fb83e7ee1e3430129911d957d5e95e554d4ab100
