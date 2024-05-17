mod world_id_bridge; 

// ** Note ** 
// These tests use the L1 handler functions as though they are external, in production, other contracts or EOAs 
// should not be able to call the L1 handlers. Only the starknet sequencer should be able to call.  

#[cfg(test)]
mod test {
    use starknet::{ContractAddress, get_caller_address, EthAddress};
    use snforge_std::{declare, ContractClass, ContractClassTrait, prank, start_prank, start_warp, CheatTarget};
    use world_id_state_bridge::stark_world_id::interface_stark_world_id::{IStarkWorldIDDispatcher, IStarkWorldIDDispatcherTrait, IStarkWorldIDSafeDispatcher, IStarkWorldIDSafeDispatcherTrait};
    use world_id_state_bridge::stark_world_id::world_id_bridge::world_id_bridge::{IWorldIDExtSafeDispatcher, IWorldIDExtSafeDispatcherTrait};
    use world_id_state_bridge::stark_world_id::StarkWorldID;
    use world_id_state_bridge::stark_world_id::world_id_bridge::WorldID;
    
    fn setup_world_id_ext() -> (ContractAddress, IStarkWorldIDSafeDispatcher) {
        let contract: ContractClass = declare("StarkWorldID");
        let mut args = ArrayTrait::new();
        args.append(111.try_into().unwrap());
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
        args.append(111.try_into().unwrap());
        args.append(10); 
        contract.deploy(@args).unwrap();
    }
    
    #[test]
    fn test_only_owner_receive_root() {
        // Setup
        let mut stark_world_id_state = StarkWorldID::contract_state_for_testing(); 
        let owner: EthAddress = 111.try_into().unwrap(); 


        // Create temp state
        StarkWorldID::constructor(ref stark_world_id_state, owner, 30);

        // Owner call Succeeds
        let root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        StarkWorldID::receive_root(ref stark_world_id_state, owner.into(), root);
    }

    #[test]
    #[should_panic]
    fn test_invalid_only_owner_receive_root() {
        // setup
        let mut stark_world_id_state = StarkWorldID::contract_state_for_testing(); 
        let owner: EthAddress = 111.try_into().unwrap(); 
        let invalid_caller: EthAddress = 222.try_into().unwrap(); 

        // Create temp state
        StarkWorldID::constructor(ref stark_world_id_state, owner, 30);

        // Owner call Fails
        let root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        StarkWorldID::receive_root(ref stark_world_id_state, invalid_caller.into(), root);
    }
}