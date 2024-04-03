use starknet::ContractAddress;

#[starknet::interface]
trait IStarkWorldID<TContractState> {
    fn transferOwnership(self: @TContractState, owner: ContractAddress, isLocal: bool);
}