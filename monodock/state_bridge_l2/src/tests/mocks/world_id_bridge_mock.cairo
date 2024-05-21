#[starknet::contract]
pub mod WorldIDBridgeMock {
    use world_id_state_bridge::stark_world_id::world_id_bridge::WorldID;

    component!(path: WorldID, storage: world_id_storage, event: WorldIDEvent);

    // External Components
    #[abi(embed_v0)]
    impl WorldIDImpl = WorldID::WorldIDImpl<ContractState>;
    #[abi(embed_v0)]
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
        WorldIDEvent: WorldID::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, tree_depth: u8) {
        self.world_id_storage._intialize(tree_depth); 
    }
}