mod IStarkWorldID;
mod ICrossDomainOwnable3;
#[starknet::contract]
mod StarkWorldID {
#[storage]
    struct Storage {
        name: felt252,
    }
}