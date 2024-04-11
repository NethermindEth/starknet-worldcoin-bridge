use world_id_state_bridge::tests::mocks::world_id_bridge_mock::WorldIDBridgeMock;
use world_id_state_bridge::stark_world_id::world_id_bridge::{WorldID};
use world_id_state_bridge::stark_world_id::world_id_bridge::WorldID::{WorldIDImpl, InternalImpl};

use starknet::ContractAddress;
use starknet::SyscallResultTrait;

type ComponentState = WorldID::ComponentState<WorldIDBridgeMock::ContractState>;


impl TestingStateDefault of Default<ComponentState> {
    fn default() -> ComponentState {
        WorldID::component_state_for_testing()
    }
}

///////////////////////////////////////////////////////////////////
///                           SUCCEEDS                          ///
///////////////////////////////////////////////////////////////////

#[test]
fn test_get_tree_depth() {
    let mut world_id: ComponentState = Default::default();
    let tree_depth: u8 = 20; 
    world_id._intialize(tree_depth);

    assert!(world_id.get_tree_depth() == tree_depth);
}

///////////////////////////////////////////////////////////////////
///                           REVERTS                           ///
///////////////////////////////////////////////////////////////////

#[test]
#[should_panic]
fn test_constructor_with_invalid_tree_depth() {
    let mut world_id: ComponentState = Default::default();
    let tree_depth: u8 = 15; 
    world_id._intialize(tree_depth);
}

