mod IStarkWorldID;
mod ICrossDomainOwnable3;
mod WorldIDBridge; 
#[starknet::contract]
mod StarkWorldID {
#[storage]
    struct Storage {
        name: felt252,
    }
}