use starknet::EthAddress;

#[starknet::interface]
pub trait ICrossDomainOwnable<TContractState> {
    fn transfer_ownership(ref self: TContractState, new_owner: EthAddress, isLocal: bool);
    fn owner(self: @TContractState) -> EthAddress;
    fn only_cross_domain_owner(self: @TContractState);
}

