
#[cfg(test)]
mod test {
    use world_id_state_bridge::tests::mocks::world_id_bridge_mock::WorldIDBridgeMock;
    use world_id_state_bridge::stark_world_id::world_id_bridge::WorldID;
    use world_id_state_bridge::stark_world_id::world_id_bridge::WorldID::{WorldIDImpl, InternalImpl};

    use starknet::ContractAddress;
    use starknet::SyscallResultTrait;
    use starknet::testing::set_block_timestamp;
    type ComponentState = WorldID::ComponentState<WorldIDBridgeMock::ContractState>;


    impl TestingStateDefault of Default<ComponentState> {
        fn default() -> ComponentState {
            WorldID::component_state_for_testing()
        }
    }

    fn setup() -> ComponentState {
        let mut world_id: ComponentState = Default::default();
        let tree_depth: u8 = 20; 
        world_id._intialize(tree_depth);

        world_id
    }

    ///////////////////////////////////////////////////////////////////
    ///                           SUCCEEDS                          ///
    ///////////////////////////////////////////////////////////////////
    #[test]
    fn test_get_tree_depth() {
        let mut world_id: ComponentState = Default::default();
        let tree_depth: u8 = 20; 
        world_id._intialize(tree_depth);

        assert!(world_id.get_tree_depth() == tree_depth, "Cannot get tree depth");
    }

    #[test]
    fn test_latest_root() {
        let mut world_id = setup();
        let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(old_root);

        let new_root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(new_root);

        assert!(world_id.latest_root() != old_root, "Latest root is not updated");
        assert!(world_id.latest_root() == new_root, "Latest root is not updated");
    }

    #[test]
    fn test_set_root_expiry() {
        let mut world_id = setup();
        let expiry: u256 = 1000000;
        
        world_id._set_root_history_expiry(expiry);
        assert!(world_id.root_history_expiry() == expiry, "Root history is not set");
    }

    // snforge does not support startnet::testing::set_block_timestamp
    // #[test]
    // fn test_valid_require_valid_root() {
    //     let mut world_id = setup();
    //     set_block_timestamp(10); 
    //     world_id._set_root_history_expiry(1000000); // set expiry

    //     let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
    //     world_id._receive_root(old_root);

    //     let new_root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
    //     world_id._receive_root(new_root);

    //     world_id.require_valid_root(new_root);

    //     //Test old root has not expired
    //     world_id.require_valid_root(old_root);
    // }

    ///////////////////////////////////////////////////////////////////
    ///                           PANICS                            ///
    ///////////////////////////////////////////////////////////////////

    // #[test]
    // #[should_panic]
    fn test_invalid_require_valid_root() {
        let mut world_id = setup();
        let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(old_root);

        let new_root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(new_root);

        world_id.require_valid_root(old_root);
    }

    // snforge does not support startnet::testing::set_block_timestamp
    // #[test]
    // #[should_panic]
    // fn test_expired_require_valid_root() {
    //     let mut world_id = setup();
    //     let timestamp: u64 = 10; 
    //     set_block_timestamp(timestamp); 

    //     let expiry: u64 = 1000000;
    //     world_id._set_root_history_expiry(expiry.into()); // set expiry

    //     let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
    //     world_id._receive_root(old_root);

    //     let new_root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
    //     world_id._receive_root(new_root);
        
    //     let new_timestamp: u64 = expiry + timestamp + 1; 
    //     set_block_timestamp(new_timestamp); 
    //     world_id.require_valid_root(old_root);
    // }

    #[test]
    #[should_panic]
    fn test_constructor_with_invalid_tree_depth() {
        let mut world_id: ComponentState = Default::default();
        let tree_depth: u8 = 15; 
        world_id._intialize(tree_depth);
    }
}