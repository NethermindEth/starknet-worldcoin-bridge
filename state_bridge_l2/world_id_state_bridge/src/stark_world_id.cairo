//! # Title
//! 
//! Starknet World ID Bridge Smart Contract
//!
//! ## Author 
//! 
//! Nethermind
//!
//! ## License
//! 
//! MIT

pub mod interface_stark_world_id;
pub mod cross_domain_ownable;
pub mod world_id_bridge; 

#[starknet::contract]
pub mod StarkWorldID {
    use super::world_id_bridge::WorldID;
    use super::cross_domain_ownable::CrossDomainOwnable;
    pub use super::interface_stark_world_id;
    pub use super::interface_stark_world_id::IStarkWorldIDDispatcher;
    use starknet::EthAddress;

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
    }

    #[constructor]
    pub fn constructor(ref self: ContractState, l1_address: EthAddress, tree_depth: u8) {
        self.cross_domain_ownable_storage._initialize(l1_address); 
        self.world_id_storage._intialize(tree_depth); 
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                                ROOT MIRRORING                           ///
    ///////////////////////////////////////////////////////////////////////////////

    /// This function is called by the state bridge contract when it forwards a new root to
    ///         the bridged WorldID.
    /// 
    /// # Arguments
    ///
    /// * 'newRoot' - The value of the new root.
    ///
    /// # Panics
    /// 
    /// Panics with CannotOverwriteRoot - If the root already exists in the root history.
    /// Panics with string - If the caller is not the owner.
    #[l1_handler]
    pub fn receive_root(ref self: ContractState, from_address: felt252, new_root: u256) {
        self.cross_domain_ownable_storage.only_cross_domain_owner(from_address); 
        self.world_id_storage._receive_root(new_root); 
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////
    
    /// Sets the amount of time it takes for a root in the root history to expire.
    ///
    /// # Arguments
    /// 
    /// * 'expiryTime' - The new amount of time it takes for a root to expire.
    /// 
    /// # Panics
    /// 
    /// Panics - If the caller is not the owner.
    #[l1_handler]
    pub fn set_root_history_expiry(ref self: ContractState, from_address: felt252, expiry_time: felt252) {
        self.cross_domain_ownable_storage.only_cross_domain_owner(from_address); 
        self.world_id_storage._set_root_history_expiry(expiry_time); 
    }

    /// This function transfers ownership to another L1 State Bridge Contract
    /// 
    /// # Notice
    /// 
    /// This function is not transferring ownership to another EOA, instead it is specifically
    ///     transferring the contract address of the L1 contract. This is in case the L1 contract
    ///     needs to be replaced/modified/etc.
    #[l1_handler]
    pub fn transfer_ownership(ref self: ContractState, from_address: felt252, new_owner: EthAddress){
        self.cross_domain_ownable_storage.only_cross_domain_owner(from_address); 
        self.cross_domain_ownable_storage.transfer_ownership(from_address, new_owner); 
    }
}