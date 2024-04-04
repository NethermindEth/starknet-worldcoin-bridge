use starknet::ContractAddress;

#[starknet::interface]
trait IStarkWorldID<TContractState> {
    fn transferOwnership(ref self: TContractState, owner: ContractAddress, isLocal: bool);
}

