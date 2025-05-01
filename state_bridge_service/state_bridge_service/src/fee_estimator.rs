use std::convert::identity;

use crate::{abi::abi::IWorldIDRouter, config::config::Config};
use ethers::{providers::JsonRpcClient, types::{H160, U256}};
use starknet::{core::types::{BlockId, BlockTag, EthAddress, Felt, MsgFromL1}, providers::{jsonrpc::HttpTransport, Provider, Url}};
use ethers::types::Address;
use starknet::providers::JsonRpcClient as StarknetJsonRPClient;
use dotenv::dotenv; 

use crate::config::{config::BridgeAddressBook, constants::defaults::HANDLE_RECEIVE_ROOT_SELECTOR};

pub async fn get_fee<P: JsonRpcClient + 'static>(config: Config<P>, bridge_addresses: BridgeAddressBook) -> eyre::Result<Felt>{
    let provider = StarknetJsonRPClient::new(HttpTransport::new(Url::parse("https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/gfOoly96YO_xfWIsfGytkypxZ7snOUw6")?));
    let l1_msg = build_msg_from_l1(config, bridge_addresses).await?;

    let fee = provider.estimate_message_fee(l1_msg, BlockId::Tag(BlockTag::Latest)).await?.overall_fee;

    Ok(fee)
}

pub async fn build_msg_from_l1<P: JsonRpcClient + 'static>(config: Config<P>, bridge_addresses: BridgeAddressBook) -> eyre::Result<MsgFromL1> {
    dotenv().ok();

    let from_address = EthAddress::from_hex(&std::env::var("SEPOLIA_ADDRESS")?)?;
    let to_address = Felt::from(EthAddress::from_bytes(*bridge_addresses.bridge_l1.as_fixed_bytes()));
    let entry_point_selector = Felt::from_hex_unchecked(HANDLE_RECEIVE_ROOT_SELECTOR);
    let payload = get_root(config).await?;
    
    Ok(
        MsgFromL1 { from_address, to_address, entry_point_selector, payload}
    )
    // pub payload: Vec<Felt>,
}

pub async fn get_root<P: JsonRpcClient + 'static>(config: Config<P>) -> eyre::Result<Vec<Felt>> {
    let identity_manager_contract = IWorldIDRouter::new(config.address_book.worldid_router, config.provider);
    let root = identity_manager_contract.latest_root().await?;
    
    // Parse payload - uint256 splits into two felt252
    let latest_root_0 = root.low_u128().into();
    let latest_root_1 = (root >> 128).as_u128().into();
    let root: Vec<Felt> = vec![latest_root_0, latest_root_1];

    Ok(root)
}