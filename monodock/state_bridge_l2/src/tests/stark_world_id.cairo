mod world_id_bridge; 

#[cfg(test)]
mod test {
    use starknet::{ContractAddress, get_caller_address};
    use snforge_std::{declare, ContractClass, ContractClassTrait, prank, start_prank, start_warp, CheatTarget};
    use world_id_state_bridge::stark_world_id::interface_stark_world_id::{IStarkWorldIDDispatcher, IStarkWorldIDDispatcherTrait, IStarkWorldIDSafeDispatcher, IStarkWorldIDSafeDispatcherTrait};
    use world_id_state_bridge::stark_world_id::world_id_bridge::world_id_bridge::{IWorldIDExtSafeDispatcher, IWorldIDExtSafeDispatcherTrait};

    fn setup_world_id_ext() -> (ContractAddress, IStarkWorldIDSafeDispatcher) {
        let contract: ContractClass = declare("StarkWorldID");
        let mut args = ArrayTrait::new();
        args.append(20); 

        let contract_address = contract.precalculate_address(@args);

        contract.deploy(@args).unwrap();
        let dispatcher = IStarkWorldIDSafeDispatcher {contract_address};
        (contract_address, dispatcher)
    }

    #[test]
    #[should_panic]
    fn test_invalid_constructor_root() {
        let contract = declare("StarkWorldID");
        let mut args = ArrayTrait::new();
        args.append(10); 
        contract.deploy(@args).unwrap();
    }
    
    #[test]
    #[feature("safe_dispatcher")]
    fn test_only_owner_receive_root() {
        // setup
        let contract: ContractClass = declare("StarkWorldID");
        let mut args = ArrayTrait::new();
        args.append(20); 
        
        let contract_address = contract.precalculate_address(@args);

        start_prank(CheatTarget::One(contract_address), 111.try_into().unwrap()); // set caller to 111
        contract.deploy(@args).unwrap();

        let dispatcher = IStarkWorldIDSafeDispatcher {contract_address};
        
        // Owner call Succeeds
        let root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        let owner_call = dispatcher.receive_root(root);
        assert!(owner_call.is_ok()); 

        // Outsider call Fails
        start_prank(CheatTarget::One(contract_address), 123.try_into().unwrap());
        let outside_call = dispatcher.receive_root(root);
        assert!(outside_call.is_err());
    }

    #[test]
    #[feature("safe_dispatcher")]
    fn test_valid_require_valid_root() {
        let (contract_address, dispatcher) = setup_world_id_ext(); 

        let initial_block = 100;
        start_warp(CheatTarget::One(contract_address), initial_block); // set block timestamp = 100
        
        let expiry: u64 = 1000; 
        dispatcher.set_root_history_expiry(expiry.into()).unwrap(); 

        let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        dispatcher.receive_root(old_root).unwrap();
        let new_root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        dispatcher.receive_root(new_root).unwrap();

        let world_id_dispatcher = IWorldIDExtSafeDispatcher {contract_address};

        // Root is Valid 
        let old_root_call = world_id_dispatcher.require_valid_root(old_root);
        assert!(old_root_call.is_ok()); 
        let new_root_call = world_id_dispatcher.require_valid_root(new_root);
        assert!(new_root_call.is_ok()); 

        // Root is Expired
        start_warp(CheatTarget::One(contract_address), expiry + initial_block + 1); // set block timestamp = 100
        let old_root_call = world_id_dispatcher.require_valid_root(old_root);
        assert!(old_root_call.is_err()); 

        // Root is Valid (latest root is always valid)
        let new_root_call = world_id_dispatcher.require_valid_root(new_root);
        assert!(new_root_call.is_ok()); 

    }

    #[test]
    #[feature("safe_dispatcher")]
    fn test_valid_overwrite_latest_root() {
        let (_, dispatcher) = setup_world_id_ext(); 

        let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        dispatcher.receive_root(old_root).unwrap();

        let new_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        let invalid_overwrite_call = dispatcher.receive_root(new_root);
        assert!(invalid_overwrite_call.is_ok()); 
    }
}