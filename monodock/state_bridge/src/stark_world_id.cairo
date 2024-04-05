mod interface_stark_world_id;
mod interface_crossdomain_ownable3;
mod world_id_bridge; 

//  TODO: Add ownerOnly
#[starknet::contract]
mod StarkWorldID {
    use super::world_id_bridge::WorldID;
    use super::interface_stark_world_id;

    component!(path: WorldID, storage: world_id_storage, event: WorldIDEvent);

    // External Components
    #[abi(embed_v0)]
    impl WorldIDImpl = WorldID::WorldIDImpl<ContractState>;
    impl WorldIDImplVerify = WorldID::WorldIDImplVerify<ContractState>;

    // Internal Components
    impl WorldIDInternalImpl = WorldID::InternalImpl<ContractState>; 

    #[storage]
    struct Storage {
        #[substorage(v0)]
        world_id_storage: WorldID::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        WorldIDEvent: WorldID::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, tree_depth: u8) {
        self.world_id_storage._intialize(tree_depth); 
    }

    impl StarkWorldID of interface_stark_world_id::IStarkWorldID<ContractState> {
        ///////////////////////////////////////////////////////////////////////////////
        ///                               ROOT MIRRORING                            ///
        ///////////////////////////////////////////////////////////////////////////////

        /// @notice This function is called by the state bridge contract when it forwards a new root to
        ///         the bridged WorldID.
        /// @dev    This function can revert if Nethermind's CrossDomainMessenger stops processing proofs
        ///         or if Nethermind stops submitting them. 
        ///         Sequencer needs to include changes to the CrossDomainMessenger contract on L1,
        ///         not economically penalized if messages are not included, however the fraud prover (Cannon)
        ///         can force the sequencer to include it.
        ///
        /// @param newRoot The value of the new root.
        ///
        /// @custom:reverts CannotOverwriteRoot If the root already exists in the root history.
        /// @custom:reverts string If the caller is not the owner.
        fn receive_root(ref self: ContractState, new_root: u256) {
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
            self.world_id_storage._set_root_history_expiry(expiry_time); 
        }

    }

    

}