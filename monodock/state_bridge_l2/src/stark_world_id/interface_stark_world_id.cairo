use starknet::EthAddress; 

// Both functions should be called with ownerOnly equivalent
#[starknet::interface]
pub trait IStarkWorldID<TContractState> {
    fn receive_root(ref self: TContractState, from_address: felt252, new_root: u256);
    fn set_root_history_expiry(ref self: TContractState, from_address: felt252, expiry_time: u256);
    fn transfer_ownership(ref self: TContractState, from_address: felt252, new_owner: EthAddress);
}