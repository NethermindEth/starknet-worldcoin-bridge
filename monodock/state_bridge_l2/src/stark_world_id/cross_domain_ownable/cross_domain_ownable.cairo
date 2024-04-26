#[starknet::component]
pub mod CrossDomainOwnable {
    use world_id_state_bridge::stark_world_id::cross_domain_ownable::interface_cross_domain_ownable;
    use starknet::{ContractAddress, EthAddress, get_caller_address};
    const zero: felt252 = 0;

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

    pub impl CrossDomainOwnableImpl<TContractState, +HasComponent<TContractState>> of interface_cross_domain_ownable::ICrossDomainOwnable<ComponentState<TContractState>> {
        #[l1_handler]
        fn transfer_ownership(ref self: ComponentState<TContractState>, new_owner: EthAddress, isLocal: bool){
            // assert(!new_owner.is_zero(), Errors::ZERO_ADDRESS_OWNER);
            self.only_cross_domain_owner(); 
            
            self.emit(NewL1Owner {previous_l1_owner: self.l1_owner.read(), new_l1_owner: new_owner});
            self.l1_owner.write(new_owner);
        }

        #[l1_handler]   
        fn owner(self: @ComponentState<TContractState>) -> EthAddress{
            self.l1_owner.read()
        }

        #[l1_handler]
        fn only_cross_domain_owner(self: @ComponentState<TContractState>) {
             let caller = get_caller_address();
            
            assert(caller.into() != zero, Errors::ZERO_ADDRESS_CALLER);
            //assert(caller == self.l1_owner.read(), Errors::NOT_OWNER);
        }
    }
}