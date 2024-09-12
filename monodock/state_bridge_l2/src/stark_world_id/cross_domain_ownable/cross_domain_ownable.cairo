#[starknet::component]
pub mod CrossDomainOwnable {
    use world_id_state_bridge::stark_world_id::cross_domain_ownable::interface_cross_domain_ownable;
    use starknet::EthAddress;
    const ZERO: felt252 = 0;

    #[storage]
    struct Storage{
        l1_owner: EthAddress,
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  ERRORS                                 ///
    ///////////////////////////////////////////////////////////////////////////////

    pub mod Errors {
        pub const NOT_OWNER: felt252 = 'Caller is not the owner';
        pub const ZERO_ADDRESS_CALLER: felt252 = 'Caller is the zero address';
        pub const ZERO_ADDRESS_OWNER: felt252 = 'New owner is the zero address';
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  EVENTS                                 ///
    ///////////////////////////////////////////////////////////////////////////////

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        l1_owner_set: NewL1Owner,
    }

    #[derive(Drop, starknet::Event)]
    struct NewL1Owner {
        #[key]
        previous_l1_owner: EthAddress,
        #[key]
        new_l1_owner: EthAddress,

    }
    #[generate_trait]
    pub impl InternalImpl<TContractState, +HasComponent<TContractState>> of InternalTrait<TContractState> {
        fn _initialize(ref self: ComponentState<TContractState>, owner: EthAddress) {

            self.emit(NewL1Owner {previous_l1_owner: self.l1_owner.read(), new_l1_owner: owner});
            self.l1_owner.write(owner); 
        }
    }

    pub impl CrossDomainOwnableImpl<TContractState, +HasComponent<TContractState>> of interface_cross_domain_ownable::ICrossDomainOwnable<ComponentState<TContractState>> {
        fn transfer_ownership(ref self: ComponentState<TContractState>, from_address: felt252, new_owner: EthAddress){
            assert(new_owner.into() != ZERO, Errors::ZERO_ADDRESS_OWNER);
            self.only_cross_domain_owner(from_address); 
            
            self.emit(NewL1Owner {previous_l1_owner: self.l1_owner.read(), new_l1_owner: new_owner});
            self.l1_owner.write(new_owner);
        }

        fn owner(self: @ComponentState<TContractState>) -> EthAddress{
            self.l1_owner.read()
        }

        fn only_cross_domain_owner(self: @ComponentState<TContractState>, from_address: felt252) {
            assert(from_address != ZERO, Errors::ZERO_ADDRESS_CALLER);
            assert(from_address == self.l1_owner.read().into(), Errors::NOT_OWNER);
        }
    }
}