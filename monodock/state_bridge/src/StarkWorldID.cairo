mod IStarkWorldID;
mod ICrossDomainOwnable3;
mod IWorldIDBridge;
mod WorldIDBridge; 
#[starknet::contract]
mod StarkWorldID {
#[storage]
    struct Storage {
        name: felt252,
    }
}