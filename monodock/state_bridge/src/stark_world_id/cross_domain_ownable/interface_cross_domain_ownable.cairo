use starknet::ContractAddress;

#[starknet::interface]
pub trait ICrossDomainOwnable<TContractState> {
    fn transferOwnership(ref self: TContractState, owner: ContractAddress, isLocal: bool);
}

