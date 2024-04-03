#[starknet::interface]
trait IStarkWorldID<TContractState> {
    fn receiveRoot(self: @TContractState, newRoot: u256);
}