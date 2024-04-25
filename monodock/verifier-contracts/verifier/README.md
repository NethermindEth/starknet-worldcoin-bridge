# Starknet Verifier Contract

This repository contains a Starknet contract that implements a verifier for a zero-knowledge proof system. The contract is written in Cairo and utilizes the bn128 elliptic curve for pairing-based cryptography.

## Contract Overview

The main components of the contract are:

- `IVerifier`: An interface trait that defines the `verify_proof` function, which takes a proof and input and returns a boolean indicating whether the proof is valid.
- `Verifier`: The main contract module that implements the `IVerifier` trait and provides the functionality for verifying proofs.
- `Storage`: A struct representing the contract's storage.
- `PrivateTrait`: A trait containing private functions used internally by the contract.

## Verification Process

The contract verifies a proof by performing the following steps:

1. Extract the verification key parameters and proof parameters from the provided `Proof` and `Input` structs.
2. Compute the public input scalar multiplication using the `public_input_multi_scalar_mul` function.
3. Perform the necessary elliptic curve pairings using the `ec_pairings` function.
4. Check if the final exponentiation of the pairing result equals the identity element (Fq12::one()).

## Dependencies

The contract relies on the following external libraries:

- `bn`: A library for elliptic curve operations and pairing-based cryptography.
- `verifier`: A module containing constants and structs related to the verifier.

## Usage

To use this contract, you need to deploy it on a Starknet network and interact with it using a Starknet-compatible wallet or application.

The main entry point for verifying a proof is the `verify_proof` function, which takes the following parameters:

- `proof`: A `Proof` struct containing the proof elements.
- `inputs`: An `Input` struct containing the public inputs for the proof.

The function returns a boolean value indicating whether the proof is valid.

## Testing

The contract includes a set of tests to ensure its correctness and functionality. The tests are written using the `snforge_std` testing framework.

### Integration Tests

- `test_verify_integration_success`: This test deploys the verifier contract and verifies a valid proof. It asserts that the verification succeeds.
- `test_verify_integration_fails`: This test deploys the verifier contract and attempts to verify an invalid proof. It expects the verification to fail and panic.

### Unit Tests

- `test_alphabeta_precompute`: This test checks the correctness of the precomputed `alphabeta_miller` value by comparing it with the result of the `ate_miller_loop` function.
- `test_points_on_curve`: This test verifies that the points in the verification key (alpha, beta, gamma, delta, ic0, ic1, ic2, ic3, ic4) lie on their respective elliptic curves (G1 or G2).

### Helper Functions

- `deploy`: This function deploys the verifier contract and returns an instance of `IVerifierDispatcher` for interacting with the deployed contract.
- `is_on_curve_g1`: This function checks if a given point lies on the G1 curve.
- `is_on_curve_g2`: This function checks if a given point lies on the G2 curve.

To run the tests, you need to have a starknet-foundry testing environment set up and the necessary dependencies installed.
```bash
snforge test --detailed-resources --max-n-steps 1000000000 
```