# Starknet State Bridge Cairo Contracts

Contains all of the smart contracts on L2.

## Requirements

Install: 
-	[scarb](https://docs.swmansion.com/scarb/download.html#requirements) cairo contract compiler. 
-  [starkli](https://book.starkli.rs/installation) Deploy and declare smart contracts. 
-  [katana](https://book.dojoengine.org/toolchain/katana/interact) Local starknet node
-  [starknet-foundry](https://github.com/foundry-rs/starknet-foundry) Starknet Foundry for testing
Versions used:
- scarb [2.8.0]
- starkli [0.2.9]
- katana [0.7.0-alpha.1]

Git submodules are used for the library, install via:
```bash
git submodule update --init --recursive
```

## Unit Testing
CD
```
cd world_id_state_bridge
```
Run 
``` 
snforge test
```
