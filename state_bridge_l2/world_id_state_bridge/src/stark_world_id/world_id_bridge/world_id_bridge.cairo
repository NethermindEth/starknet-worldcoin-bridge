//! WorldIDBridge Interface
//! 
//! ## Author 
//! 
//! Nethermind
//! 
//! ## Notice
//! 
//! Interfaces that will be exposed externally 
#[starknet::interface]
pub trait IWorldIDExt<TContractState> {
    fn require_valid_root(self: @TContractState, root: u256);
    fn latest_root(self: @TContractState) -> u256;
    fn root_history_expiry(self: @TContractState) -> felt252;
    fn get_tree_depth(self: @TContractState) -> u8;
}

//! Bridged World ID
//! 
//! ## Author 
//! 
//! Nethermind
//! 
//! ## Overview
//!
//! The state bridges manage the root history of the identity merkle tree on Starknet. 
//!
//! ## Notice
//! 
//! This contract is very explicitly a component. 
#[starknet::component]
pub mod WorldID {
    use starknet::get_block_timestamp;
    use starknet::storage::Map;
    use starknet::SyscallResultTrait;
    use world_id_state_bridge::stark_world_id::world_id_bridge::interface_world_id;
    use world_id_state_bridge::stark_world_id::world_id_bridge::semaphore_tree_depth_validator::validate;
    use world_id_state_bridge::stark_world_id::world_id_bridge::groth16_verifier_constants::{N_PUBLIC_INPUTS, vk, ic, precomputed_lines};
    use garaga::definitions::{G1Point, G1G2Pair};
    use garaga::groth16::multi_pairing_check_bn254_3P_2F_with_extra_miller_loop_result;
    use garaga::utils::calldata::{deserialize_full_proof_with_hints_bn254};
    use garaga::ec_ops::{G1PointTrait, G2PointTrait, ec_safe_add};

    // const ECIP_OPS_CLASS_HASH: felt252 =
    //     0x25bdbb933fdbef07894633039aacc53fdc1f89c6cf8a32324b5fefdcc3d329e;
    const ECIP_OPS_CLASS_HASH: felt252 =
        0x7918f484291eb154e13d0e43ba6403e62dc1f5fbb3a191d868e2e37359f8713;

    const NULL_ROOT_TIME: u8 = 0;
    const ONE_WEEK: felt252 = 604800;

    #[storage]
    struct Storage {
        tree_depth: u8, // immutable
        root_history_expiry: felt252,
        latest_root: u256,
        root_history: Map::<u256, u128>,
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  ERRORS                                 ///
    ///////////////////////////////////////////////////////////////////////////////

    pub mod Errors {
        /// @notice Emitted when the provided semaphore tree depth is unsupported.
        pub const UNSUPPORTED_TREE_DEPTH: felt252 = 'UNSUPPORTED_TREE_DEPTH';
        
        /// @notice Emitted when attempting to validate a root that has expired.
        pub const EXPIRED_ROOT: felt252 = 'EXPIRED_ROOT';
        
        /// @notice Emitted when attempting to validate a root that has yet to be added to the root history
        pub const NON_EXISTENT_ROOT: felt252 = 'NON_EXISTENT_ROOT';
        
        /// @notice Emitted when attempting to update the timestamp for a root that already has one.
        pub const CANNOT_OVERWRITE_ROOT: felt252 = 'CANNOT_OVERWRITE_ROOT';
        
        /// @notice Emitted if the latest root is requested but the bridge has not seen any roots yet.
        pub const NO_ROOTS_SEEN: felt252 = 'NO_ROOTS_SEEN';
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  EVENTS                                 ///
    ///////////////////////////////////////////////////////////////////////////////
    
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        root_added: RootAdded,
        root_history_expiry_set: RootHistoryExpirySet,
    }

    /// Emitted when a new root is received by the contract.
    /// 
    /// # Parameters
    /// 
    /// * 'root' - The value of the root that was added.
    /// * 'param' - timestamp The timestamp of insertion for the given root.
    #[derive(Drop, starknet::Event)]
    struct RootAdded {
        #[key]
        root: u256,
        timestamp: u128,
    }

    /// Emitted when the expiry time for the root history is updated.
    /// 
    /// # Parameters
    /// 
    /// * 'newExpiry' - The new expiry time.
    #[derive(Drop, starknet::Event)]
    struct RootHistoryExpirySet {
        #[key]
        new_expiry: felt252,
    }

    // External Functions
    #[embeddable_as(WorldIDImpl)]
    impl WorldID<TContractState, +HasComponent<TContractState>> of super::IWorldIDExt<ComponentState<TContractState>> {

        /// Reverts if the provided root value is not valid.
        ///
        /// # Arguments
        /// 
        /// * 'root' - The root of the merkle tree to check for validity.
        ///
        /// # Panics 
        /// 
        /// Panics with ExpiredRoot - If the provided `root` has expired.
        /// Panics with NonExistentRoot - If the provided `root` does not exist in the history.
        /// 
        /// # Notice
        /// A root is valid if it is either the latest root, or not the latest root but has not
        ///      expired.
        fn require_valid_root(self: @ComponentState<TContractState>, root: u256) {
            if root == self.latest_root.read() {
                return;
            }

            let root_timestamp: u256 = self.root_history.read(root).into(); 

            assert(root_timestamp != 0, Errors::NON_EXISTENT_ROOT);

            // Check for underflow?
            assert((get_block_timestamp().into() - root_timestamp).into() <= self.root_history_expiry.read().into(), Errors::EXPIRED_ROOT); 
        }

        ///////////////////////////////////////////////////////////////////////////////
        ///                              DATA MANAGEMENT                            ///
        ///////////////////////////////////////////////////////////////////////////////

        /// Gets the value of the latest root.
        ///
        /// # Panics
        /// 
        /// Panics with NoRootsSeen - If there is no latest root.
        fn latest_root(self: @ComponentState<TContractState>) -> u256 {
            assert(self.latest_root.read() != 0, Errors::NO_ROOTS_SEEN); 

            self.latest_root.read()
        }

        /// Gets the amount of time it takes for a root in the root history to expire.
        fn root_history_expiry(self: @ComponentState<TContractState>) -> felt252{
            self.root_history_expiry.read()
        }

        /// Gets the Semaphore tree depth the contract was initialized with.
        fn get_tree_depth(self: @ComponentState<TContractState>) -> u8{
            self.tree_depth.read()
        }
    }

    #[embeddable_as(WorldIDImplVerify)]
    impl WorldIDVerify<TContractState, +HasComponent<TContractState>> of interface_world_id::IWorldID<ComponentState<TContractState>> {

        ///////////////////////////////////////////////////////////////////////////////
        ///                             SEMAPHORE PROOFS                            ///
        ///////////////////////////////////////////////////////////////////////////////

        /// A verifier for the semaphore protocol.
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
        /// 
        /// # Notice
        /// 
        /// The the mpcheck_hint, small_Q, and msm_hint are precomputed using Garaga's pythonic backend. Use the Garaga verifier to verify.
        /// https://github.com/keep-starknet-strange/garaga
        fn verify_proof(
            self: @ComponentState<TContractState>, 
            full_proof_with_hints: Span<felt252>,
        ) {
            let fph = deserialize_full_proof_with_hints_bn254(full_proof_with_hints);
            let groth16_proof = fph.groth16_proof;
            let mpcheck_hint = fph.mpcheck_hint;
            let small_Q = fph.small_Q;
            let msm_hint = fph.msm_hint;

            // Require Valid Root
            self.require_valid_root(groth16_proof.public_inputs[0].clone()); 

            groth16_proof.a.assert_on_curve(0);
            groth16_proof.b.assert_on_curve(0);
            groth16_proof.c.assert_on_curve(0);

            let ic = ic.span();

            let vk_x: G1Point = match ic.len() {
                0 => panic!("Malformed VK"),
                1 => *ic.at(0),
                _ => {
                    // Start serialization with the hint array directly to avoid copying it.
                    let mut msm_calldata: Array<felt252> = msm_hint;
                    // Add the points from VK and public inputs to the proof.
                    Serde::serialize(@ic.slice(1, N_PUBLIC_INPUTS), ref msm_calldata);
                    Serde::serialize(@groth16_proof.public_inputs, ref msm_calldata);
                    // Complete with the curve indentifier (0 for BN254):
                    msm_calldata.append(0);

                    // Call the multi scalar multiplication endpoint on the Garaga ECIP ops contract
                    // to obtain vk_x.
                    let mut _vx_x_serialized = core::starknet::syscalls::library_call_syscall(
                        ECIP_OPS_CLASS_HASH.try_into().unwrap(),
                        selector!("msm_g1"),
                        msm_calldata.span()
                    )
                        .unwrap_syscall();

                    ec_safe_add(
                        Serde::<G1Point>::deserialize(ref _vx_x_serialized).unwrap(), *ic.at(0), 0
                    )
                }
            };

            // Perform the pairing check.
            assert(multi_pairing_check_bn254_3P_2F_with_extra_miller_loop_result(
                G1G2Pair { p: vk_x, q: vk.gamma_g2 },
                G1G2Pair { p: groth16_proof.c, q: vk.delta_g2 },
                G1G2Pair { p: groth16_proof.a.negate(0), q: groth16_proof.b },
                vk.alpha_beta_miller_loop_result,
                precomputed_lines.span(),
                mpcheck_hint,
                small_Q
            ) == true, 'Verification Failed');
        }   
    }
    
    // Internal Functions
    #[generate_trait]
    pub impl InternalImpl<TContractState, +HasComponent<TContractState>> of InternalTrait<TContractState> {
        ///////////////////////////////////////////////////////////////////////////////
        ///                               CONSTRUCTION                              ///
        ///////////////////////////////////////////////////////////////////////////////

        /// Constructs a new instance of the state bridge.
        ///
        /// # Arguments
        /// 
        /// * 'tree_depth' - The depth of the identities merkle tree.
        fn _intialize(ref self: ComponentState<TContractState>, tree_depth: u8) {
            // initialize ROOT_HISTORY_EXPIRY
            self.root_history_expiry.write(ONE_WEEK); 
            assert(validate(tree_depth), Errors::UNSUPPORTED_TREE_DEPTH); 
            self.tree_depth.write(tree_depth);
        }

        ///////////////////////////////////////////////////////////////////////////////
        ///                              ROOT MIRRORING                             ///
        ///////////////////////////////////////////////////////////////////////////////

        /// This function is called by the state bridge contract when it forwards a new root to
        ///         the bridged WorldID.
        ///
        /// # Arguments
        /// 
        /// * 'new_root' - The value of the new root.
        ///
        /// # Panics
        /// 
        /// Panic with CannotOverwriteRoot - If the root already exists in the root history.
        fn _receive_root(ref self: ComponentState<TContractState>, new_root: u256) {
            let existing_timestamp: u128 = self.root_history.read(new_root);

            assert(existing_timestamp == NULL_ROOT_TIME.into(), Errors::CANNOT_OVERWRITE_ROOT);

            let curr_timestamp: u128 = get_block_timestamp().into();

            self.latest_root.write(new_root);
            self.root_history.write(new_root, curr_timestamp); 

            self.emit(RootAdded {root: new_root, timestamp: curr_timestamp});
        }       

        /// Sets the amount of time it takes for a root in the root history to expire.
        /// 
        /// # Arguments
        /// 
        /// * 'expiry_time' - The new amount of time it takes for a root to expire.
        fn _set_root_history_expiry(ref self: ComponentState<TContractState>, expiry_time: felt252) {
            self.root_history_expiry.write(expiry_time); 
            self.emit(RootHistoryExpirySet {new_expiry: expiry_time});
        }
    }

}
