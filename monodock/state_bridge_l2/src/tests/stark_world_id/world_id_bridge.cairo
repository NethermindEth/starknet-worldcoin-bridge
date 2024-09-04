mod tests {
    use world_id_state_bridge::tests::mocks::world_id_bridge_mock::WorldIDBridgeMock;
    use world_id_state_bridge::stark_world_id::world_id_bridge::WorldID;
    use world_id_state_bridge::stark_world_id::world_id_bridge::WorldID::{WorldIDImpl, InternalImpl};
    use snforge_std::{declare, ContractClass, ContractClassTrait};

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
    fn test_get_tree_depth() {
        let mut world_id: ComponentState = Default::default();
        let tree_depth: u8 = 20; 
        world_id._intialize(tree_depth);

        assert!(world_id.get_tree_depth() == tree_depth, "Cannot get tree depth");
    }

    fn test_latest_root() {
        let mut world_id = setup();
        let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(old_root);

        let new_root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(new_root);

        assert!(world_id.latest_root() != old_root, "Latest root is not updated");
        assert!(world_id.latest_root() == new_root, "Latest root is not updated");
    }

    fn test_set_root_expiry() {
        let mut world_id = setup();
        let expiry: felt252 = 1000000;
        
        world_id._set_root_history_expiry(expiry);
        assert!(world_id.root_history_expiry() == expiry, "Root history is not set");
    }

    fn test_valid_overwrite_latest_root() {
        let mut world_id = setup();

        let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(old_root);

        let new_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(new_root);
    }


    /// Robust Root Expiry test is found in integration tests 
    fn test_valid_require_valid_root() {
        let mut world_id = setup();        

        let expiry: felt252 = 1000; 
        world_id._set_root_history_expiry(expiry);

        let old_root: u256 = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(old_root);

        let new_root: u256 = 0x012cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        world_id._receive_root(new_root);

        world_id.require_valid_root(new_root);
        assert!(world_id.latest_root() == new_root);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           PANICS                            ///
    ///////////////////////////////////////////////////////////////////

    fn test_constructor_with_invalid_tree_depth() {
        let mut world_id: ComponentState = Default::default();
        let tree_depth: u8 = 15; 
        world_id._intialize(tree_depth);
        panic!("Invalid Tree Depth")
    }
}