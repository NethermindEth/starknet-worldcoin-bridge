use ethers::{contract::EthEvent, types::U256};

pub mod abi;

#[derive(Debug, Clone, EthEvent)]
#[ethevent(name = "TreeChanged", abi = "TreeChanged(uint256,uint8,uint256)")]
pub struct TreeChanged {
    #[ethevent(indexed)]
    pub pre_root: U256,
    #[ethevent(indexed)]
    pub kind: u8,
    #[ethevent(indexed)]
    pub post_root: U256,
}
