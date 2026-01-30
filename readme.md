<div align="center">
  <h1>Worldcoin <=> Starknet Bridge</h1>
</div>

## About
Contains the L1 and L2 smart contracts and the relay service that watches World ID identity roots on Ethereum, submits updates to Starknet, and keeps the bridge state in sync across networks.

Key Details:
- Propogate the root of the identity merkle tree from L1 to L2 using Starknet's Cross Messenger.
- Built-in Groth16 verifier, easy verification using [Garaga](https://github.com/keep-starknet-strange/garaga)
- Local bridge setup testing

## Sepolia Test 
L1 address: https://sepolia.etherscan.io/address/0x5aA8058C1E090d8299162b021e32a284Ec55f3D0

L2 address: https://sepolia.voyager.online/contract/0x01167d6979330fcc6633111d72416322eb0e3b78ad147a9338abea3c04edfc8a#transactions

## Mainnet
L1 address: https://etherscan.io/address/0x651065427cB3022839764b142c6098c1833Df6DD

L2 address: https://voyager.online/contract/0x01794b8e558902e1e6a1d122d94de40fc7d482d11ea7f8e5cb56dd393646a378#transactions

## Disclaimer
Contracts are not yet audited.

