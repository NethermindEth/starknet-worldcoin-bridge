# Starknet State Bridge Solidity Contracts

Contains all of the smart contracts on L1.

## Requirements

Install: 
- 	[foundry](https://book.getfoundry.sh/getting-started/installation) Foundry for testing

Git submodules are used for the library, install via:
```bash
git submodule update --init --recursive
```

## Unit Testing
Setup
```
cp anvil.env .env
source .env
```
Run 
``` 
forge test
```
