# Starknet messaging local development

This repository aims at giving the detailed steps to locally work
on Starknet messaging with `Anvil` and `Katana`.

## Requirements

Please before start, install:

-   [scarb](https://docs.swmansion.com/scarb/) to build cairo contracts.
-   [starkli](https://github.com/xJonathanLEI/starkli) to interact with Katana.
-   [katana](https://www.dojoengine.org/en/) to install Katana, that belongs to dojo.
-   [foundry](https://book.getfoundry.sh/getting-started/installation) to interact with Anvil.

Please check the versions, before starting:
- scarb [2.3.1]
- starkli [0.1.20]
- katana [0.4.4]
- forge [0.2.0]

If it's your first time cloning the repository, please install forge dependencies as follow:
```bash
cd solidity
forge install
```

## Setup Ethereum contracts

To setup Ethereum part for local testing, please follow those steps:

1. Start Anvil in a new terminal with the command `anvil`.

2. In an other terminal, change directory into the solidity folder:
   ```bash
   cd solidity

   # Copies the example of anvil configuration file into .env that is loaded by
   # foundry automatically.
   cp anvil.env .env

   # Ensure all variables are exported for the use of forge commands.
   source .env
   ```

3. Then, we will deploy the `StarknetMessagingLocal` contract that simulates the work
   done by the `StarknetMessaging` core contract on Ethereum. Then we will deploy the `ContractMsg.sol`
   to send/receive message. To do so, run the following:
   ```bash
   forge script script/LocalTesting.s.sol:LocalSetup --broadcast --rpc-url ${ETH_RPC_URL}
   ```

3. Keep this terminal open for later use to send transactions on Anvil.


## Setup Starknet contracts

To setup Starknet contract, please follow those steps:

1. Update katana on the 0.4.4 version to match starkli compatible version (temporary fix due to RPC incompatibility):
   ```bash
   starkliup -v 0.1.20
   dojoup -v 0.4.4
   ```

2. Then open a terminal and starts katana by passing the messaging configuration where Anvil contract address and account keys are setup:
   ```bash
   katana --messaging config.json
   ```

   Katana will now poll anvil logs exactly as the Starknet sequencer does on the `StarknetMessaging` contract on ethereum.

3. In a new terminal, go into cairo folder and use starkli to declare and deploy the contracts:
   ```bash
   cd cairo
   
   # To ensure starkli env variables are setup correctly.
   source katana.env

   scarb build

   starkli declare ./target/dev/messaging_tuto_contract_msg.contract_class.json --keystore-password ""

   starkli deploy 0x02d6b666ade3a9ee98430d565830604b90954499c590fa05a9844bdf4d3a574b \
       --salt 0x1234 \
       --keystore-password ""
   ```
4. Keep this terminal open to later send transactions on Katana.

## Interaction between the two chains

Once you have both dev nodes setup with contracts deployed, we can start interacting with them.
You can use `starkli` to send transactions.

### To send messages L1 -> L2:
```bash
# In the terminal that is inside solidity folder you've used to run forge script previously (ensure you've sourced the .env file).
forge script script/SendMessage.s.sol:Value --broadcast --rpc-url ${ETH_RPC_URL}
```
You will then see Katana picking up the messages, and executing exactly as Starknet would
do with Ethereum on testnet or mainnet.

Example here where you can see the details of the message and the event being emitted `ValueReceivedFromL1`.
```bash
2024-04-05T10:59:01.199739Z  INFO messaging: L1Handler transaction added to the pool:
|      tx_hash     | 0x784b3039f0c2c2e3e516f04722f29de44b91a3a39ecd6b17899508e0e0c8d16
| contract_address | 0x754519eb51784c690fbd3deafb0e4c4bc017e6f60955fc7d0ba3e9b9b894831
|     selector     | 0x5421de947699472df434466845d68528f221a52fce7ad2934c5dae2e1f1cdc
|     calldata     | [0xe7f1725e7734ce288f8367e1bb143e90bb3f0512, 0x970bed]
2024-04-05T10:59:01.199767Z  INFO txpool: Transaction received | Hash: 0x784b3039f0c2c2e3e516f04722f29de44b91a3a39ecd6b17899508e0e0c8d16
```
You can try to change the payload into the scripts to see how the contract on starknet behaves receiveing the message. Try to set both values to 0 for the struct. In the case of the value, you'll see a warning in Katana saying `Invalid value` because the contract is expected `9898989`.

## Work In Progress
1. Dockerisation of Katana.
2. Docker-compose for running Anvil & Katana and deploy contracts.
3. A script to check the l1-l2 messaging.
4. Documentation for the contracts, docker-compose and GitHub Action.
