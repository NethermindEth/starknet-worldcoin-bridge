use starknet::ContractAddress;

/// @title WorldID Interface
/// @author Worldcoin
/// @notice The interface to the Semaphore Groth16 proof verification for WorldID.
#[starknet::interface]
trait IWorldID<TContractState> {
    fn intialize(ref self: TContractState, tree_depth: u8);

    fn verify_proof(ref self: TContractState,
        root: u256,
        signalHash: u256,
        nullifierHash: u256,
        externalNullifierHash: u256,
        proof: Array<u256>);

    fn receive_root(ref self: TContractState, new_root: u256);
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
    const ROOT_HISTORY_EXPIRY: u256 = 604800; // 1 week in seconds
    const NULL_ROOT_TIME: u8 = 0;
    #[storage]
    struct Storage {
        tree_depth: u8, // immutable
        latest_root: u256,
        root_history: LegacyMap::<u256, u128>,
        //semaphoreVerifier: Semaphore,

    }

    mod Errors {
        const UNSUPPORTED_TREE_DEPTH: felt252 = 'UNSUPPORTED_TREE_DEPTH';
        const EXPIRED_ROOT: felt252 = 'EXPIRED_ROOT';
        const NON_EXISTENT_ROOT: felt252 = 'NON_EXISTENT_ROOT';
        const CANNOT_OVERWRITE_ROOT: felt252 = 'CANNOT_OVERWRITE_ROOT';
        const NO_ROOTS_SEEN: felt252 = 'NO_ROOTS_SEEN';
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        root_added: RootAdded,
        root_history_expiry_set: RootHistoryExpirySet,
    }

    #[derive(Drop, starknet::Event)]
    struct RootAdded {
        #[key]
        root: u256,
        timestamp: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct RootHistoryExpirySet {
        #[key]
        new_expiry: u256,
    }

    #[embeddable_as(WorldIDImpl)]
    impl WorldID<TContractState, +HasComponent<TContractState>> of super::IWorldID<ComponentState<TContractState>> {
        fn intialize(ref self: ComponentState<TContractState>, tree_depth: u8) {
            assert(validate(tree_depth), 'UNSUPPORTED_TREE_DEPTH'); // Why doesn't Errors::UNSUPPORTED_TREE_DEPTH work?
            self.tree_depth.write(tree_depth);
        }

        fn receive_root(ref self: ComponentState<TContractState>, new_root: u256) {
            let existing_timestamp: u256 = self.root_history.read(new_root);

        }

        // TODO
        fn verify_proof(ref self: ComponentState<TContractState>, root: u256,
        signalHash: u256,
        nullifierHash: u256,
        externalNullifierHash: u256,
        proof: Array<u256>) {

        }
    }
    

}