use starknet::EthAddress;

#[starknet::interface]
pub trait ICrossDomainOwnable<TContractState> {
    fn transfer_ownership(ref self: TContractState, from_address: felt252, new_owner: EthAddress);
    fn owner(self: @TContractState) -> EthAddress;
    fn only_cross_domain_owner(self: @TContractState, from_address: felt252);
}

