// Interface for internal function implementation

#[starknet::interface]
trait IWorldID<TContractState> {
    fn _intialize(ref self: TContractState, tree_depth: u8); // constructor
    fn _receive_root(ref self: TContractState, new_root: u256);
    fn _set_root_history_expiry(ref self: TContractState, expiry_time: u256);
}