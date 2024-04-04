use starknet::ContractAddress;

/// @title WorldID Interface
/// @author Nethermind
/// @notice The interface to the Semaphore Groth16 proof verification for WorldID.
#[starknet::interface]
trait IWorldIDExt<TContractState> {

    fn verify_proof(self: @TContractState,
        root: u256,
        signalHash: u256,
        nullifierHash: u256,
        externalNullifierHash: u256,
        proof: Array<u256>);

    fn require_valid_root(self: @TContractState, root: u256);

    fn latest_root(self: @TContractState) -> u256;

    fn root_history_expiry(self: @TContractState) -> u256;

    fn get_tree_depth(self: @TContractState) -> u8;
}

// SemaphoreTreeDepthValidator 
#[external(v0)]
fn validate(tree_depth: u8) -> bool {
    let min_depth: u8 = 16;
    let max_depth: u8 = 32;
    tree_depth >= min_depth && tree_depth <= max_depth
}

#[starknet::component]
mod WorldID {
    // TODO: Add Semaphore Verifier
    use super::validate;
    use starknet::get_block_timestamp;
    
    const NULL_ROOT_TIME: u8 = 0;
    #[storage]
    struct Storage {
        tree_depth: u8, // immutable
        root_history_expiry: u256,
        latest_root: u256,
        root_history: LegacyMap::<u256, u128>,
        //semaphoreVerifier: Semaphore,

    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  ERRORS                                 ///
    ///////////////////////////////////////////////////////////////////////////////

    mod Errors {
        /// @notice Emitted when the provided semaphore tree depth is unsupported.
        const UNSUPPORTED_TREE_DEPTH: felt252 = 'UNSUPPORTED_TREE_DEPTH';
        
        /// @notice Emitted when attempting to validate a root that has expired.
        const EXPIRED_ROOT: felt252 = 'EXPIRED_ROOT';
        
        /// @notice Emitted when attempting to validate a root that has yet to be added to the root history
        const NON_EXISTENT_ROOT: felt252 = 'NON_EXISTENT_ROOT';
        
        /// @notice Emitted when attempting to update the timestamp for a root that already has one.
        const CANNOT_OVERWRITE_ROOT: felt252 = 'CANNOT_OVERWRITE_ROOT';
        
        /// @notice Emitted if the latest root is requested but the bridge has not seen any roots yet.
        const NO_ROOTS_SEEN: felt252 = 'NO_ROOTS_SEEN';
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  EVENTS                                 ///
    ///////////////////////////////////////////////////////////////////////////////
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        root_added: RootAdded,
        root_history_expiry_set: RootHistoryExpirySet,
    }

    /// @notice Emitted when a new root is received by the contract.
    ///
    /// @param root The value of the root that was added.
    /// @param timestamp The timestamp of insertion for the given root.
    #[derive(Drop, starknet::Event)]
    struct RootAdded {
        #[key]
        root: u256,
        timestamp: u128,
    }

    /// @notice Emitted when the expiry time for the root history is updated.
    ///
    /// @param newExpiry The new expiry time.
    #[derive(Drop, starknet::Event)]
    struct RootHistoryExpirySet {
        #[key]
        new_expiry: u256,
    }

    

    // External Functions
    #[embeddable_as(WorldIDImpl)]
    impl WorldID<TContractState, +HasComponent<TContractState>> of super::IWorldIDExt<ComponentState<TContractState>> {

        /// @notice Reverts if the provided root value is not valid.
        /// @dev A root is valid if it is either the latest root, or not the latest root but has not
        ///      expired.
        ///
        /// @param root The root of the merkle tree to check for validity.
        ///
        /// @custom:reverts ExpiredRoot If the provided `root` has expired.
        /// @custom:reverts NonExistentRoot If the provided `root` does not exist in the history.
        fn require_valid_root(self: @ComponentState<TContractState>, root: u256) {
            if root == self.latest_root.read() {
                return;
            }

            let root_timestamp: u256 = self.root_history.read(root).into(); 

            assert(root_timestamp != 0, 'NON_EXISTENT_ROOT');

            assert((get_block_timestamp().into() - root_timestamp).into() > self.root_history_expiry.read(), 'EXPIRED_ROOT'); 
        }

        // TODO: 
        ///////////////////////////////////////////////////////////////////////////////
        ///                             SEMAPHORE PROOFS                            ///
        ///////////////////////////////////////////////////////////////////////////////

        /// @notice A verifier for the semaphore protocol.
        /// @dev Note that a double-signaling check is not included here, and should be carried by the
        ///      caller.
        ///
        /// @param root The root of the Merkle tree
        /// @param signalHash A keccak256 hash of the Semaphore signal
        /// @param nullifierHash The nullifier hash
        /// @param externalNullifierHash A keccak256 hash of the external nullifier
        /// @param proof The zero-knowledge proof
        ///
        /// @custom:reverts string If the zero-knowledge proof cannot be verified for the public inputs.
        fn verify_proof(self: @ComponentState<TContractState>, root: u256,
        signalHash: u256,
        nullifierHash: u256,
        externalNullifierHash: u256,
        proof: Array<u256>) {   

        }   

        ///////////////////////////////////////////////////////////////////////////////
        ///                              DATA MANAGEMENT                            ///
        ///////////////////////////////////////////////////////////////////////////////

        /// @notice Gets the value of the latest root.
        ///
        /// @custom:reverts NoRootsSeen If there is no latest root.
        fn latest_root(self: @ComponentState<TContractState>) -> u256 {
            assert(self.latest_root.read() != 0, 'NO_ROOTS_SEEN'); 

            self.latest_root.read()
        }

        /// @notice Sets the amount of time it takes for a root in the root history to expire.
        /// @dev When implementing this function, ensure that it is guarded on `onlyOwner`.
        ///
        /// @param expiryTime The new amount of time it takes for a root to expire.
        fn root_history_expiry(self: @ComponentState<TContractState>) -> u256{
            self.root_history_expiry.read()
        }

        /// @notice Gets the Semaphore tree depth the contract was initialized with.
        fn get_tree_depth(self: @ComponentState<TContractState>) -> u8{
            self.tree_depth.read()
        }
    }

    // Internal Functions
    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        ///////////////////////////////////////////////////////////////////////////////
        ///                               CONSTRUCTION                              ///
        ///////////////////////////////////////////////////////////////////////////////

        /// @notice Constructs a new instance of the state bridge.
        ///
        /// @param _treeDepth The depth of the identities merkle tree.
        fn _intialize(ref self: ComponentState<TContractState>, tree_depth: u8) {
            // initialize ROOT_HISTORY_EXPIRY
            self.root_history_expiry.write(604800);  // 1 week in seconds
            //assert(validate(tree_depth), 'UNSUPPORTED_TREE_DEPTH'); // Why doesn't Errors::UNSUPPORTED_TREE_DEPTH work?
            self.tree_depth.write(tree_depth);
        }

        ///////////////////////////////////////////////////////////////////////////////
        ///                              ROOT MIRRORING                             ///
        ///////////////////////////////////////////////////////////////////////////////

        /// @notice This function is called by the state bridge contract when it forwards a new root to
        ///         the bridged WorldID.
        /// @dev Intended to be called from a privilege-checked implementation of `receiveRoot` or an
        ///      equivalent operation.
        ///
        /// @param newRoot The value of the new root.
        ///
        /// @custom:reverts CannotOverwriteRoot If the root already exists in the root history.
        fn _receive_root(ref self: ComponentState<TContractState>, new_root: u256) {
            let existing_timestamp: u128 = self.root_history.read(new_root);

            assert(existing_timestamp == NULL_ROOT_TIME.into(), 'CANNOT_OVERWRITE_ROOT');

            let curr_timestamp: u128 = get_block_timestamp().into();

            self.latest_root.write(new_root);
            self.root_history.write(new_root, curr_timestamp); 

            self.emit(RootAdded {root: new_root, timestamp: curr_timestamp});
        }       

        /// @notice Sets the amount of time it takes for a root in the root history to expire.
        /// @dev Intended to be called from a privilege-checked implementation of `receiveRoot`.
        ///
        /// @param expiryTime The new amount of time it takes for a root to expire.
        fn _set_root_history_expiry(ref self: ComponentState<TContractState>, expiry_time: u256) {
            self.root_history_expiry.write(expiry_time); 

            self.emit(RootHistoryExpirySet {new_expiry: expiry_time});
        }
    }

}