use crate::abi::abi::IWorldIDRouter;
use crate::config::cli::{Cli, Network};
use crate::config::constants::{
    addresses::*, chain_ids::*, defaults::HANDLE_RECEIVE_ROOT_SELECTOR,
};

use std::sync::Arc;

use dotenv::dotenv;
use ethers::providers::{JsonRpcClient as EthersJsonRpcClient, Middleware, Provider as EthersProvider, Ws};
use ethers::signers::{LocalWallet, Signer};
use ethers::types::{Address, H160};
use starknet::core::types::{BlockId, BlockTag, EthAddress, Felt, MsgFromL1};
use starknet::providers::jsonrpc::{HttpTransport, JsonRpcTransport as StarknetJsonRpcTransport};
use starknet::providers::{
    JsonRpcClient as StarknetJsonRPClient, Provider as StarknetProvider, Url,
};

#[derive(Clone, Debug)]
pub struct Config<P, T>
where
    P: Middleware + 'static,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    pub l1_provider: Arc<P>,
    pub l2_provider: Arc<StarknetJsonRPClient<T>>,
    pub owner: LocalWallet,
    pub world_address_book: WorldAddressBook,
    pub bridge_address_book: BridgeAddressBook,
}

pub struct EnvironmentConfig {
    pub http_local: String,
    pub test_private_key: String,
}

#[derive(Clone, Debug)]
pub struct WorldAddressBook {
    pub worldid_router: Address,
    pub identity_manager: Address,
}

#[derive(Clone, Debug)]
pub struct BridgeAddressBook {
    pub bridge_l1: Address,
    pub bridge_l2: Felt,
}

impl Default for BridgeAddressBook {
    fn default() -> Self {
        Self {
            bridge_l1: SEPOLIA_BRIDGE_L1.parse::<H160>().unwrap(),
            bridge_l2: SEPOLIA_BRIDGE_L2.parse::<Felt>().unwrap(),
        }
    }
}

impl BridgeAddressBook {
    fn new_mainnet() -> Self {
        Self {
            bridge_l1: MAINNET_BRIDGE_L1.parse::<H160>().unwrap(),
            bridge_l2: MAINNET_BRIDGE_L2.parse::<Felt>().unwrap(),
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

impl Config<EthersProvider<Ws>, HttpTransport> {
    pub async fn new_from_cli(cli: &Cli) -> Result<Self, eyre::Report> {
        dotenv().ok();

        let (
            ethers_ws_provider,
            starknet_http_provider,
            private_key,
            chain_id,
            world_address_book,
            bridge_address_book,
        ) = match cli.network {
            Network::Sepolia => (
                std::env::var("SEPOLIA_ETHEREUM_WS_PROVIDER").unwrap(),
                std::env::var("SEPOLIA_STARKNET_HTTP_PROVIDER").unwrap(),
                std::env::var("SEPOLIA_ETHEREUM_PRIVATE_KEY").unwrap(),
                SEPOLIA_CHAIN_ID,
                Default::default(),
                Default::default(),
            ),
            Network::Mainnet => (
                std::env::var("MAINNET_ETHEREUM_WS_PROVIDER").unwrap(),
                std::env::var("MAINNET_STARKNET_HTTP_PROVIDER").unwrap(),
                std::env::var("MAINNET_ETHEREUM_PRIVATE_KEY").unwrap(),
                MAINNET_CHAIN_ID,
                WorldAddressBook::new_mainnet(),
                BridgeAddressBook::new_mainnet(),
            ),
        };

        let ethers_ws = Ws::connect(ethers_ws_provider).await?;
        let starknet_http = HttpTransport::new(Url::parse(&starknet_http_provider)?);
        let ethers_provider = EthersProvider::new(ethers_ws);
        let starknet_provider = StarknetJsonRPClient::new(starknet_http);
        let wallet = private_key.parse::<LocalWallet>()?.with_chain_id(chain_id);

        Ok(Self {
            l1_provider: Arc::new(ethers_provider),
            l2_provider: Arc::new(starknet_provider),
            owner: wallet,
            world_address_book,
            bridge_address_book,
        })
    }
}

impl<P, T> Config<P, T>
where
    P: Middleware + 'static,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    pub async fn get_fee(&self) -> eyre::Result<Felt> {
        let l1_msg = self.build_msg_from_l1().await?;
        let fee = self
            .l2_provider
            .estimate_message_fee(l1_msg, BlockId::Tag(BlockTag::Latest))
            .await?
            .overall_fee;

        Ok(fee)
    }

    pub async fn build_msg_from_l1(&self) -> eyre::Result<MsgFromL1> {
        let from_address =
            EthAddress::from_bytes(*self.bridge_address_book.bridge_l1.as_fixed_bytes());
        let to_address = self.bridge_address_book.bridge_l2;
        let entry_point_selector = Felt::from_hex_unchecked(HANDLE_RECEIVE_ROOT_SELECTOR);
        let payload = self.get_root().await?;

        Ok(MsgFromL1 {
            from_address,
            to_address,
            entry_point_selector,
            payload,
        })
        // pub payload: Vec<Felt>,
    }

    pub async fn get_root(&self) -> eyre::Result<Vec<Felt>> {
        let identity_manager_contract = IWorldIDRouter::new(
            self.world_address_book.worldid_router,
            self.l1_provider.clone(),
        );

        // Parse payload - uint256 splits into two felt252
        let root = identity_manager_contract.latest_root().await?;
        let latest_root_0 = root.low_u128().into();
        let latest_root_1 = (root >> 128).as_u128().into();

        Ok(vec![latest_root_0, latest_root_1])
    }

    // For estimating fees when latest root is already propagated.
    pub async fn get_dummy_root(&self) -> eyre::Result<Vec<Felt>> {
        let dummy_root_0 = Felt::from(2_u128 << 128 - 1);
        let dummy_root_1 = Felt::from(2_u128 << 128 - 1);

        Ok(vec![dummy_root_0, dummy_root_1])
    }
}
