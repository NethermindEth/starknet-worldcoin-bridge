// Both functions should be called with ownerOnly equivalent
#[starknet::interface]
pub trait IStarkWorldID<TContractState> {
    fn receive_root(ref self: TContractState, new_root: u256);

    fn set_root_history_expiry(ref self: TContractState, expiry_time: u256);
}