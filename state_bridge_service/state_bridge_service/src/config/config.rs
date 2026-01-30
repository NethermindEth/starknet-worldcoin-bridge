use crate::abi::abi::IIdentityManager;
use crate::config::cli::{Cli, Fee, Network};
use crate::config::constants::{
    addresses::*, chain_ids::*, defaults::HANDLE_RECEIVE_ROOT_SELECTOR,
};
use crate::config::utils::{felts_to_u256, into_felt};

use std::sync::Arc;

use dotenv::dotenv;
use ethers::providers::{Middleware, Provider as EthersProvider, Ws};
use ethers::signers::{LocalWallet, Signer};
use ethers::types::{Address, H160, U256};
use starknet::core::types::{
    BlockId, BlockTag, ContractExecutionError, EthAddress, FeeEstimate, Felt, FunctionCall,
    MsgFromL1, StarknetError,
};
use starknet::core::utils::get_selector_from_name;
use starknet::providers::jsonrpc::{HttpTransport, JsonRpcTransport as StarknetJsonRpcTransport};
use starknet::providers::{
    JsonRpcClient as StarknetJsonRPClient, Provider as StarknetProvider, ProviderError, Url,
};

#[derive(Clone, Debug)]
pub struct Config<M, T>
where
    M: Middleware + 'static,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    pub l1_provider: Arc<M>,
    pub l2_provider: Arc<StarknetJsonRPClient<T>>,
    pub owner: LocalWallet,
    pub world_address_book: WorldAddressBook,
    pub bridge_address_book: BridgeAddressBook,
    pub fee_type: Fee,
    pub l1_ws_primary: String,
    pub l1_ws_fallback: Option<String>,
}

pub struct EnvironmentConfig {
    pub http_local: String,
    pub test_private_key: String,
}

#[derive(Clone, Debug)]
pub enum L2RootResult {
    Root(U256),
    NoRootsSeen,
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
            ethers_ws_fallback,
            starknet_http_provider,
            private_key,
            chain_id,
            world_address_book,
            bridge_address_book,
        ) = match cli.network {
            Network::Sepolia => (
                std::env::var("SEPOLIA_ETHEREUM_WS_PROVIDER").unwrap(),
                std::env::var("SEPOLIA_ETHEREUM_WS_PROVIDER_FALLBACK").ok(),
                std::env::var("SEPOLIA_STARKNET_HTTP_PROVIDER").unwrap(),
                std::env::var("SEPOLIA_ETHEREUM_PRIVATE_KEY").unwrap(),
                SEPOLIA_CHAIN_ID,
                Default::default(),
                Default::default(),
            ),
            Network::Mainnet => (
                std::env::var("MAINNET_ETHEREUM_WS_PROVIDER").unwrap(),
                std::env::var("MAINNET_ETHEREUM_WS_PROVIDER_FALLBACK").ok(),
                std::env::var("MAINNET_STARKNET_HTTP_PROVIDER").unwrap(),
                std::env::var("MAINNET_ETHEREUM_PRIVATE_KEY").unwrap(),
                MAINNET_CHAIN_ID,
                WorldAddressBook::new_mainnet(),
                BridgeAddressBook::new_mainnet(),
            ),
        };

        let ethers_ws = Ws::connect(ethers_ws_provider.clone()).await?;
        let starknet_http = HttpTransport::new(Url::parse(&starknet_http_provider)?);
        let ethers_provider = EthersProvider::new(ethers_ws);
        let starknet_provider = StarknetJsonRPClient::new(starknet_http);
        let wallet = private_key.parse::<LocalWallet>()?.with_chain_id(chain_id);

        Ok(Self {
            fee_type: cli.fee,
            l1_provider: Arc::new(ethers_provider),
            l2_provider: Arc::new(starknet_provider),
            owner: wallet,
            world_address_book,
            bridge_address_book,
            l1_ws_primary: ethers_ws_provider,
            l1_ws_fallback: ethers_ws_fallback,
        })
    }
}

impl<M, T> Config<M, T>
where
    M: Middleware + 'static,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    pub fn identity_manager(&self) -> Address {
        self.world_address_book.identity_manager
    }

    pub fn l1_bridge_address(&self) -> Address {
        self.bridge_address_book.bridge_l1
    }

    pub fn wallet(&self) -> &LocalWallet {
        &self.owner
    }

    pub fn l1_provider(&self) -> Arc<M> {
        self.l1_provider.clone()
    }

    pub fn l2_provider(&self) -> Arc<StarknetJsonRPClient<T>> {
        self.l2_provider.clone()
    }

    pub fn l1_ws_primary(&self) -> &str {
        &self.l1_ws_primary
    }

    pub fn l1_ws_fallback(&self) -> Option<&str> {
        self.l1_ws_fallback.as_deref()
    }

    pub async fn estimate_messaging_fee(&self, root: Vec<Felt>) -> eyre::Result<FeeEstimate> {
        let l1_msg = self.build_msg_from_l1(root).await?;
        let fee = self
            .l2_provider
            .estimate_message_fee(l1_msg, BlockId::Tag(BlockTag::Latest))
            .await?;

        Ok(fee)
    }

    pub async fn build_msg_from_l1(&self, root: Vec<Felt>) -> eyre::Result<MsgFromL1> {
        let from_address =
            EthAddress::from_bytes(*self.bridge_address_book.bridge_l1.as_fixed_bytes());
        let to_address = self.bridge_address_book.bridge_l2;
        let entry_point_selector = Felt::from_hex_unchecked(HANDLE_RECEIVE_ROOT_SELECTOR);

        Ok(MsgFromL1 {
            from_address,
            to_address,
            entry_point_selector,
            payload: root,
        })
    }

    #[cfg(not(feature = "debug"))]
    pub async fn get_root(&self) -> eyre::Result<Vec<Felt>> {
        let identity_manager_contract = IIdentityManager::new(
            self.world_address_book.identity_manager,
            self.l1_provider.clone(),
        );

        // Parse payload - uint256 splits into two felt252
        let root = identity_manager_contract.latest_root().await?;
        let root = into_felt(root)?;

        Ok(root)
    }

    #[cfg(not(feature = "debug"))]
    pub async fn get_l1_root_u256(&self) -> eyre::Result<U256> {
        let identity_manager_contract = IIdentityManager::new(
            self.world_address_book.identity_manager,
            self.l1_provider.clone(),
        );

        Ok(identity_manager_contract.latest_root().await?)
    }

    #[cfg(not(feature = "debug"))]
    pub async fn get_l2_root_result(&self) -> eyre::Result<L2RootResult> {
        let selector = get_selector_from_name("latest_root")?;
        let call = FunctionCall {
            contract_address: self.bridge_address_book.bridge_l2,
            entry_point_selector: selector,
            calldata: Vec::new(),
        };

        tracing::info!(
            l2_contract = %self.bridge_address_book.bridge_l2,
            selector = %selector,
            "Calling L2 latest_root()"
        );

        let result = self
            .l2_provider
            .call(call, BlockId::Tag(BlockTag::Latest))
            .await;

        match result {
            Ok(result) => Ok(L2RootResult::Root(felts_to_u256(&result)?)),
            Err(err) => {
                if is_no_roots_error(&err) {
                    tracing::info!("L2 latest_root() returned NO_ROOTS_SEEN");
                    Ok(L2RootResult::NoRootsSeen)
                } else {
                    tracing::warn!(error = ?err, "L2 latest_root() call failed");
                    Err(err.into())
                }
            }
        }
    }

    #[cfg(not(feature = "debug"))]
    pub async fn get_l2_root_u256(&self) -> eyre::Result<U256> {
        match self.get_l2_root_result().await? {
            L2RootResult::Root(root) => Ok(root),
            L2RootResult::NoRootsSeen => {
                eyre::bail!("L2 latest_root not available (NO_ROOTS_SEEN)")
            }
        }
    }

    // For estimating fees when latest root is already propagated.
    #[cfg(feature = "debug")]
    pub async fn get_root(&self) -> eyre::Result<Vec<Felt>> {
        let dummy_root_0 = Felt::from(2_u128 << 128 - 1);
        let dummy_root_1 = Felt::from(2_u128 << 128 - 1);

        Ok(vec![dummy_root_0, dummy_root_1])
    }

    #[cfg(feature = "debug")]
    pub async fn get_l1_root_u256(&self) -> eyre::Result<U256> {
        Ok(U256::from(2_u128 << 128 - 1))
    }

    #[cfg(feature = "debug")]
    pub async fn get_l2_root_result(&self) -> eyre::Result<L2RootResult> {
        Ok(L2RootResult::Root(U256::from(2_u128 << 128 - 1)))
    }

    #[cfg(feature = "debug")]
    pub async fn get_l2_root_u256(&self) -> eyre::Result<U256> {
        Ok(U256::from(2_u128 << 128 - 1))
    }
}

fn is_no_roots_error(error: &ProviderError) -> bool {
    if let ProviderError::StarknetError(StarknetError::ContractError(data)) = error {
        return contract_error_contains_no_roots(&data.revert_error);
    }

    let msg = error.to_string();
    is_no_roots_seen_message(&msg)
}

fn contract_error_contains_no_roots(error: &ContractExecutionError) -> bool {
    match error {
        ContractExecutionError::Message(msg) => is_no_roots_seen_message(msg),
        ContractExecutionError::Nested(inner) => {
            let msg = format!("{:?}", inner.error);
            is_no_roots_seen_message(&msg)
        }
    }
}

fn is_no_roots_seen_message(message: &str) -> bool {
    let upper = message.to_uppercase();
    upper.contains("NO_ROOTS_SEEN")
        || upper.contains("4E4F5F524F4F54535F5345454E")
}
