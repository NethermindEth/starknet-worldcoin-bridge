use std::sync::Arc;

use crate::config::constants::{addresses::*, chain_ids::*};
use dotenv::dotenv;
use ethers::prelude::*;

use super::cli::{Cli, Network};

pub struct Config<P: JsonRpcClient> {
    pub provider: Arc<Provider<P>>,
    pub owner: LocalWallet,
    pub address_book: AddressBook,
}

pub struct EnvironmentConfig {
    pub http_local: String,
    pub test_private_key: String,
}

pub struct AddressBook {
    pub worldid_router: Address,
    pub identity_manager: Address,
}

impl Default for AddressBook {
    fn default() -> Self {
        Self {
            worldid_router: SEPOLIA_WORLDID_ROUTER.parse::<H160>().unwrap(),
            identity_manager: SEPOLIA_IDENTITY_MANAGER.parse::<H160>().unwrap(),
        }
    }
}

impl AddressBook {
    fn new_mainnet() -> Self {
        Self {
            worldid_router: MAINNET_WORLDID_ROUTER.parse::<H160>().unwrap(),
            identity_manager: MAINNET_IDENTITY_MANAGER.parse::<H160>().unwrap(),
        }
    }
}

impl Config<Ws> {
    pub async fn new_from_cli(cli: &Cli) -> Result<Self, eyre::Report> {
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
                AddressBook::new_mainnet(),
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
