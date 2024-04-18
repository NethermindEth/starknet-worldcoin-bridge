pub mod interface_stark_world_id;
mod cross_domain_ownable;
pub mod world_id_bridge; 

//  TODO: Add CrossDomainMessenger
#[starknet::contract]
pub mod StarkWorldID {
    use super::world_id_bridge::WorldID;
    pub use super::interface_stark_world_id;
    pub use super::interface_stark_world_id::IStarkWorldIDDispatcher;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::get_caller_address;

    component!(path: WorldID, storage: world_id_storage, event: WorldIDEvent);
    component!(path: OwnableComponent , storage: ownable_storage, event: OwnableEvent);

    // External Components
    #[abi(embed_v0)]
    impl WorldIDImpl = WorldID::WorldIDImpl<ContractState>;
    #[abi(embed_v0)]
    impl WorldIDImplVerify = WorldID::WorldIDImplVerify<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>; 

    // Internal Components
    impl WorldIDInternalImpl = WorldID::InternalImpl<ContractState>; 
    impl OwnableInernalImpl = OwnableComponent::InternalImpl<ContractState>; 

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable_storage: OwnableComponent::Storage,

        #[substorage(v0)]
        world_id_storage: WorldID::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        WorldIDEvent: WorldID::Event,
        OwnableEvent: OwnableComponent::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, tree_depth: u8) {
        self.ownable_storage.initializer(get_caller_address()); 
        self.world_id_storage._intialize(tree_depth); 
    }
    
    #[abi(embed_v0)]
    pub impl StarkWorldID of interface_stark_world_id::IStarkWorldID<ContractState> {
        ///////////////////////////////////////////////////////////////////////////////
        ///                               ROOT MIRRORING                            ///
        ///////////////////////////////////////////////////////////////////////////////

        /// @notice This function is called by the state bridge contract when it forwards a new root to
        ///         the bridged WorldID.
        /// @dev    This function can revert if Nethermind's CrossDomainMessenger stops processing proofs
        ///         or if Nethermind stops submitting them. 
        ///
        /// @param newRoot The value of the new root.
        ///
        /// @custom:reverts CannotOverwriteRoot If the root already exists in the root history.
        /// @custom:reverts string If the caller is not the owner.
        fn receive_root(ref self: ContractState, new_root: u256) {
            self.ownable_storage.assert_only_owner(); // onlyOwner
            self.world_id_storage._receive_root(new_root); 
        }

        ///////////////////////////////////////////////////////////////////////////////
        ///                              DATA MANAGEMENT                            ///
        ///////////////////////////////////////////////////////////////////////////////

        /// @notice Sets the amount of time it takes for a root in the root history to expire.
        ///
        /// @param expiryTime The new amount of time it takes for a root to expire.
        ///
        /// @custom:reverts string If the caller is not the owner.
        fn set_root_history_expiry(ref self: ContractState, expiry_time: u256) {
            self.ownable_storage.assert_only_owner(); // onlyOwner
            self.world_id_storage._set_root_history_expiry(expiry_time); 
        }
    }
}