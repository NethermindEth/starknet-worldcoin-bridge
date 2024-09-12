## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Environment Variables
- WORLD_ID_IDENTITY_MANAGER (Deployment address of the WorldID Identity Manager contract. The Identity Manager contracts are responsible for managing the Semaphore instance. Worldcoin's signup sequencers call the Identity Manager contracts to add or remove identities from the merkle tree.)
	https://etherscan.io/address/0xf7134CE138832c1456F2a91D64621eE90c2bddEa#code
- SN_MESSAGING_ADDRESS (Deterministic contract address deployed on L1 Anvil)
- STARK_WORLD_ID_ADDRESS ( Address of the Starknet Core contract that will receive the new root and timestamp) 
https://docs.starknet.io/documentation/tools/important_addresses/

Note: Not sure about STARK_WORLD_ID_ADDRESS is the correct address we require.

```shell
$ cp anvil.env .env
$ source .env
```

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/StarkStateBridge.s.sol:StarkStateBridgeScript
```
Output:
```bash
[⠊] Compiling...
[⠔] Compiling 12 files with 0.8.24
[⠒] Solc 0.8.24 finished in 372.58ms
Compiler run successful with warnings:
Warning (2072): Unused local variable.
  --> script/StarkStateBridge.s.sol:14:3:
   |
14 |            StarkStateBridge starkStateBridge = new StarkStateBridge(_worldIDIden, _starkWorldI, _snMessaging);
   |            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Script ran successfully.
Gas used: 616679
```
### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
