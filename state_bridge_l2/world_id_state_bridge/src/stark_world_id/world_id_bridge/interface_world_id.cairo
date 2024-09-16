use garaga::definitions::E12DMulQuotient;
use garaga::groth16::{Groth16Proof, MPCheckHintBN254};

//! WorldID Interface
//! 
//! ## Author
//! 
//! Nethermind
//!
//! ## Overview
//! 
//! The interface to the Semaphore Groth16 proof verification for WorldID. This interface
//!     in specific is used in tandem with Garaga's on-chain verifier.
//!

/// Verifies a WorldID zero knowledge proof
/// 
/// # Arguments 
/// 
/// * 'groth16_proof' - The zero-knowledge proof (structured as below)
///     Groth16Proof {
///         a: G1Point
///         b: G2Point
///         c: G1Point
///         public_inputs: Span<u256>
///     }
///     The public inputs are in order:
///     * 'root' - The root of the Merkle tree
///     * 'signalHash' - A keccak256 hash of the Semaphore signal
///     * 'nullifierHash' - The nullifier hash
///     * 'externalNullifierHash' - A keccak256 hash of the external nullifier
/// 
/// * 'mpcheck_hint' - The check hint for BN254
/// * 'small_Q' - The small Q for BN254
/// * 'msm_hint' - The multiscalar multiplication hint for BN254
/// 
/// # Returns
/// 
/// Either panics or succeeds on verification
#[starknet::interface]
pub trait IWorldID<TContractState> {
    fn verify_proof(
        self: @TContractState,
        full_proof_with_hints: Span<felt252>,
    );
}