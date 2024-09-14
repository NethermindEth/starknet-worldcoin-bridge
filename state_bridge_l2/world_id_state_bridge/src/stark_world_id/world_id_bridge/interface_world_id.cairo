use garaga::definitions::E12DMulQuotient;
use garaga::groth16::{Groth16Proof, MPCheckHintBN254};

/// @title WorldID Interface
/// @author Worldcoin - Ported by Nethermind
/// @notice The interface to the Semaphore Groth16 proof verification for WorldID.

/// @notice Verifies a WorldID zero knowledge proof.
/// @dev Note that a double-signaling check is not included here, and should be carried by the
///      caller.
/// @dev It is highly recommended that the implementation is restricted to `view` if possible.
///
/// @param root The of the Merkle tree
/// @param signalHash A keccak256 hash of the Semaphore signal
/// @param nullifierHash The nullifier hash
/// @param externalNullifierHash A keccak256 hash of the external nullifier
/// @param proof The zero-knowledge proof
///
/// @custom:reverts string If the `proof` is invalid.
#[starknet::interface]
pub trait IWorldID<TContractState> {
    fn verify_proof(
        self: @TContractState,
        groth16_proof: Groth16Proof,
        mpcheck_hint: MPCheckHintBN254,
        small_Q: E12DMulQuotient,
        msm_hint: Array<felt252>
    );
}