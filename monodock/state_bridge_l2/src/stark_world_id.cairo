pub mod interface_stark_world_id;
pub mod cross_domain_ownable;
pub mod world_id_bridge; 

//  TODO: Add CrossDomainMessenger
#[starknet::contract]
pub mod StarkWorldID {
    use super::world_id_bridge::WorldID;
    use super::cross_domain_ownable::CrossDomainOwnable;
    pub use super::interface_stark_world_id;
    pub use super::interface_stark_world_id::IStarkWorldIDDispatcher;
    use starknet::{EthAddress,get_caller_address};

    component!(path: WorldID, storage: world_id_storage, event: WorldIDEvent);
    component!(path: CrossDomainOwnable, storage: cross_domain_ownable_storage, event: CrossDomainOwnableEvent);

    // External Components
    #[abi(embed_v0)]
    impl WorldIDImpl = WorldID::WorldIDImpl<ContractState>;
    #[abi(embed_v0)]
    impl WorldIDImplVerify = WorldID::WorldIDImplVerify<ContractState>;

    // Internal Components
    impl WorldIDInternalImpl = WorldID::InternalImpl<ContractState>; 
    impl CrossDomainOwnableInternalImpl = CrossDomainOwnable::InternalImpl<ContractState>; 
    impl CrossDomainOwnableImpl = CrossDomainOwnable::CrossDomainOwnableImpl<ContractState>; 

    #[storage]
    struct Storage {
        #[substorage(v0)]
        cross_domain_ownable_storage: CrossDomainOwnable::Storage,
        #[substorage(v0)]
        world_id_storage: WorldID::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        WorldIDEvent: WorldID::Event,
        CrossDomainOwnableEvent: CrossDomainOwnable::Event,
        ValueReceivedFromL1: ValueReceived,

    }
    #[derive(Drop, starknet::Event)]
    struct ValueReceived {
        #[key]
        l1_address: felt252,
        value: felt252,
    }
    #[constructor]
    fn constructor(ref self: ContractState, l1_address: EthAddress, tree_depth: u8) {
        self.cross_domain_ownable_storage._initialize(l1_address); 
        self.world_id_storage._intialize(tree_depth); 
    }
    #[l1_handler]
    fn msg_handler_value(ref self: ContractState, from_address: felt252, value: felt252) {
        // assert(from_address == ...);

        assert(value == 123, 'Invalid value');

        self.emit(ValueReceived { l1_address: from_address, value, });
    }

    #[l1_handler]
    fn receive_root(ref self: ContractState, from_address: felt252, new_root: u256) {
        self.cross_domain_ownable_storage.only_cross_domain_owner(from_address); 
        self.world_id_storage._receive_root(new_root); 
    }

    #[l1_handler]
    fn set_root_history_expiry(ref self: ContractState, from_address: felt252, expiry_time: felt252) {
        self.cross_domain_ownable_storage.only_cross_domain_owner(from_address); 
        self.world_id_storage._set_root_history_expiry(expiry_time); 
    }

    #[l1_handler]
    fn transfer_ownership(ref self: ContractState, from_address: felt252, new_owner: EthAddress){
        self.cross_domain_ownable_storage.transfer_ownership(from_address, new_owner); 
    }

    // Cannot use l1 handlers inside an impl, sequencer cannot find it...
    // pub impl StarkWorldID of interface_stark_world_id::IStarkWorldID<ContractState> {
    //     ///////////////////////////////////////////////////////////////////////////////
    //     ///                               ROOT MIRRORING                            ///
    //     ///////////////////////////////////////////////////////////////////////////////

    //     /// @notice This function is called by the state bridge contract when it forwards a new root to
    //     ///         the bridged WorldID.
    //     /// @dev    This function can revert if Nethermind's CrossDomainMessenger stops processing proofs
    //     ///         or if Nethermind stops submitting them. 
    //     ///
    //     /// @param newRoot The value of the new root.
    //     ///
    //     /// @custom:reverts CannotOverwriteRoot If the root already exists in the root history.
    //     /// @custom:reverts string If the caller is not the owner.
    //     #[l1_handler]
    //     fn receive_root(ref self: ContractState, from_address: felt252, new_root: u256) {
    //         self.cross_domain_ownable_storage.only_cross_domain_owner(from_address); 
    //         self.world_id_storage._receive_root(new_root); 
    //     }

    //     ///////////////////////////////////////////////////////////////////////////////
    //     ///                              DATA MANAGEMENT                            ///
    //     ///////////////////////////////////////////////////////////////////////////////

    //     /// @notice Sets the amount of time it takes for a root in the root history to expire.
    //     ///
    //     /// @param expiryTime The new amount of time it takes for a root to expire.
    //     ///
    //     /// @custom:reverts string If the caller is not the owner.
    //     #[l1_handler]
    //     fn set_root_history_expiry(ref self: ContractState, from_address: felt252, expiry_time: felt252) {
    //         self.cross_domain_ownable_storage.only_cross_domain_owner(from_address); 
    //         self.world_id_storage._set_root_history_expiry(expiry_time); 
    //     }

    //     #[l1_handler]
    //     fn transfer_ownership(ref self: ContractState, from_address: felt252, new_owner: EthAddress){
    //         self.cross_domain_ownable_storage.transfer_ownership(from_address, new_owner); 
    //     }
    // }
}