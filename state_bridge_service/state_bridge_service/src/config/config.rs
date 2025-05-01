use std::sync::Arc;

use crate::config::constants::{addresses::*, chain_ids::*};
use dotenv::dotenv;
use ethers::prelude::*;
use starknet::core::types::Felt;

use super::cli::{Cli, Network};

pub struct Config<P: JsonRpcClient> {
    pub provider: Arc<Provider<P>>,
    pub owner: LocalWallet,
    pub address_book: WorldAddressBook,
}

pub struct EnvironmentConfig {
    pub http_local: String,
    pub test_private_key: String,
}

pub struct WorldAddressBook {
    pub worldid_router: Address,
    pub identity_manager: Address,
}

pub struct BridgeAddressBook {
    pub bridge_l1: Address,
    pub bridge_l2: Felt,
}

impl Default for BridgeAddressBook {
    fn default() -> Self {
        Self {
            bridge_l1: SEPOLIA_BRIDGE_L1.parse::<H160>().unwrap(),
            bridge_l2: SEPOLIA_BRIDGE_L2.parse::<Felt>().unwrap()
        }
    }
}

impl Default for WorldAddressBook {
    fn default() -> Self {
        Self {
            worldid_router: SEPOLIA_WORLDID_ROUTER.parse::<H160>().unwrap(),
            identity_manager: SEPOLIA_IDENTITY_MANAGER.parse::<H160>().unwrap(),
        }
    }
}

impl WorldAddressBook {
    fn new_mainnet() -> Self {
        Self {
            worldid_router: MAINNET_WORLDID_ROUTER.parse::<H160>().unwrap(),
            identity_manager: MAINNET_IDENTITY_MANAGER.parse::<H160>().unwrap(),
        }
    }
}

impl Config<Ws> {
    pub async fn new_from_cli(cli: &Cli) -> Result<Self, eyre::Report> {
        dotenv().ok();

        let (ws_provider, private_key, chain_id, address_book) = match cli.network {
            Network::Sepolia => (
                std::env::var("SEPOLIA_WS_PROVIDER").unwrap(),
                std::env::var("SEPOLIA_PRIVATE_KEY").unwrap(),
                SEPOLIA_CHAIN_ID,
                Default::default(),
            ),
            Network::Mainnet => (
                std::env::var("MAINNET_WS_PROVIDER").unwrap(),
                std::env::var("MAINNET_PRIVATE_KEY").unwrap(),
                MAINNET_CHAIN_ID,
                WorldAddressBook::new_mainnet(),
            ),
        };

        let ws = Ws::connect(ws_provider).await?;
        let provider = Provider::new(ws);
        let wallet = private_key.parse::<LocalWallet>()?.with_chain_id(chain_id);

        Ok(Self {
            provider: Arc::new(provider),
            owner: wallet,
            address_book: address_book,
        })
    }
}