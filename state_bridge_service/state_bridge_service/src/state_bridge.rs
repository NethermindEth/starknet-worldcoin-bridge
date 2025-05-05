use crate::abi;
use crate::config::config::Config;
use crate::error::error::StateBridgeError;
use crate::transaction::{self, check_gas_limit};

use std::sync::Arc;

use ethers::contract::EthEvent;
use ethers::providers::{Middleware, PubsubClient, StreamExt};
use ethers::signers::{LocalWallet, Signer};
use ethers::types::{Filter, H160, U256};
use starknet::providers::jsonrpc::JsonRpcTransport as StarknetJsonRpcTransport;

use tokio::sync::mpsc;
use tokio::sync::mpsc::{Receiver, Sender};
use tokio::task::JoinHandle;
use tokio::time::{Duration, Instant};
use tracing::instrument;

//use crate::tree::Hash;

/// The `StateBridge` is responsible for monitoring root changes from the `WorldRoot`, and calling the root propogation
pub struct StateBridge<M: Middleware + 'static, T> 
where T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    // Address for the state bridge contract on layer 1
    // l1_state_bridge: H160,
    // // Wallet responsible for sending `propagateRoot` transactions
    // wallet: LocalWallet,
    // // Middleware to interact with layer 1
    // l1_middleware: Arc<M>,

    config: Arc<Config<M, T>>,
    /// Time delay between `propagateRoot()` transactions
    pub relaying_period: Duration,
    /// The number of block confirmations before a `propagateRoot()` transaction is considered finalized
    pub block_confirmations: usize,
}

impl<M, T> StateBridge<M, T> 
where 
    M: Middleware,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    /// # Arguments
    ///
    /// * l1_state_bridge - Address for the state bridge contract on layer 1.
    /// * wallet - Wallet responsible for sending `propagateRoot` transactions.
    /// * l1_middleware - Middleware to interact with layer 1.
    /// * relaying_period - Duration between successive propagateRoot() invocations.
    /// * block_confirmations - Number of block confirmations required to consider a propagateRoot() transaction as finalized.
    pub fn new(
        config: impl Into<Arc<Config<M, T>>>,
        relaying_period: Duration,
        block_confirmations: usize,
    ) -> Result<Self, StateBridgeError<M>> {
        Ok(Self {
            config: config.into(),
            relaying_period,
            block_confirmations,
        })
    }

    pub fn from_config(
        config: impl Into<Arc<Config<M, T>>>,
        relaying_period: Duration,
        block_confirmations: usize,
    ) -> Result<Self, StateBridgeError<M>>
    {
        Ok(Self {
            config: config.into(),
            relaying_period,
            block_confirmations,
        })
    }

    // // todo: separate into tokio tasks
    // pub async fn watch_and_execute<T>(&self, config: Config<M, T>) -> eyre::Result<()>
    // where
    //     T: StarknetJsonRpcTransport + Send + Sync + 'static,
    // {
    //     let fee = config.get_fee().await?.overall_fee;

    //     // Filter Events
    //     let event_name = "TreeChanged(uint256,uint8,uint256)";
    //     let filter = Filter::new()
    //         .address(config.world_address_book.worldid_router)
    //         .event(event_name);

    //     // New State Bridge Service
    //     let state_bridge =
    //         StateBridge::from_config(config, self.relaying_period, self.block_confirmations)?;

    //     // Event based root propogation
    //     let mut stream = self.l1_middleware.watch(&filter).await?.stream();

    //     while let log = stream.next().await {
    //         match log {
    //             Some(log) => {
    //                 let res = state_bridge.propagate_root(fee.to_bytes_be().into()).await;

    //                 match res {
    //                     Ok(()) => println!("ok"),
    //                     Err(e) => println!("error: {:?}", e),
    //                 }

    //                 println!("Event detected: {:?}", log);
    //             }
    //             None => {
    //                 eprintln!("Error listening to events");
    //             }
    //         }
    //     }

    //     Ok(())
    // }
    // /// Spawns a `StateBridge` task to listen for `TreeChanged` events from `WorldRoot` and propagate new roots.
    // #[instrument(skip(self))]
    // pub fn spawn(&self, value: u32) -> JoinHandle<Result<(), StateBridgeError<M>>> {
    //     let l1_state_bridge = self.l1_state_bridge;
    //     let relaying_period = self.relaying_period;
    //     let block_confirmations = self.block_confirmations;
    //     let wallet = self.wallet.clone();
    //     let l1_middleware = self.l1_middleware.clone();

    //     tracing::info!(
    //         ?l1_state_bridge,
    //         ?relaying_period,
    //         ?block_confirmations,
    //         "Spawning bridge"
    //     );

    //     tokio::spawn(async move {
    //         let mut last_propagation = Instant::now().sub(relaying_period);

    //         loop {
    //             // Sleep
    //             tokio::time::sleep(relaying_period).await;
    //             tracing::info!(?l1_state_bridge, "Sleep time elapsed");

    //             let time_since_last_propagation = Instant::now() - last_propagation;

    //             if time_since_last_propagation >= relaying_period {
    //                 tracing::info!(?l1_state_bridge, "Relaying period elapsed");

    //                 tracing::info!(?l1_state_bridge, "Propagating root");

    //                 self.propagate_root(
    //                     value,
    //                 )
    //                 .await?;

    //                 last_propagation = Instant::now();
    //             }
    //         }
    //     })
    // }
    pub async fn propagate_root(&self, value: U256) -> Result<(), StateBridgeError<M>> {
        let calldata = abi::abi::ISTATEBRIDGE_ABI
            .function("propagateRoot")?
            .encode_input(&[])?;

        let tx = transaction::fill_and_simulate_eip1559_transaction(
            calldata.into(),
            self.config.get_world_router(),
            self.config.get_wallet().address(),
            self.config.get_wallet().chain_id(),
            self.config.get_l1_provider(),
            value,
        )
        .await?;

        let gas_limit = *tx.gas().unwrap();
        if check_gas_limit(gas_limit) {
            transaction::sign_and_send_transaction(
                tx,
                &self.config.get_wallet(),
                self.block_confirmations,
                self.config.get_l1_provider(),
            )
            .await?;
        } else {
            tracing::info!("Default gas limit exceeded");
            return Err(StateBridgeError::GasLimitError(gas_limit));
        }

        Ok(())
    }
}

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



impl<M, T> StateBridge<M, T> 
    where 
    M: Middleware,
    <M as Middleware>::Provider: PubsubClient,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{   
    // Start bounded channel 
    pub async fn start (self: Arc<Self>, config: Config<M, T>) -> eyre::Result<()> 
    where 
        T: StarknetJsonRpcTransport + Send + Sync,
    {   
        let (tx, mut rx) = mpsc::channel::<TreeChanged>(1);

        let tx_config = Arc::new(config); 
        let rx_config = tx_config.clone(); 
        let tx_statebridge = self.clone(); 
        let rx_statebridge = self.clone(); 


        let listener_handle = tokio::spawn(async move {
            if let Err(e) = tx_statebridge.listen_test(tx_config, tx).await {
                eprintln!("listener exited with error: {e:#}");
            }
        });

        let executor_handle = self.execute_test(rx).await?;

        tokio::try_join!(listener_handle, executor_handle)?;

        Ok(())
    }

    pub async fn execute_test(self: Arc<Self>, mut rx: Receiver<TreeChanged>) -> eyre::Result<JoinHandle<()>> 
    where 
        T: StarknetJsonRpcTransport + Send + Sync + 'static,
    {   

        let executor_handle = tokio::spawn(async move {
            while let Some(evt) = rx.recv().await {
                println!("got = {:?}", evt);
            }

        });
        
        
           

        Ok(executor_handle)
    }

    pub async fn listen_test(&self, config: Arc<Config<M, T>>, tx: Sender<TreeChanged>) -> eyre::Result<()> 
    where 
        T: StarknetJsonRpcTransport + Send + Sync,
    {
        let filter = Filter::new()
            .address(config.world_address_book.worldid_router)
            .event(&TreeChanged::abi_signature())
            .from_block(8204458);
        let l1_provider = self.config.get_l1_provider();

        let mut stream = l1_provider.subscribe_logs(&filter).await?;

        while let Some(log) = stream.next().await {
            match TreeChanged::decode_log(&log.into()) {
                Ok(evt) => {
                    tx.send(evt).await?;      
                }
                Err(e) => tracing::warn!("non‑matching log: {e:?}"),
            }
        }

        Ok(())
    }

    pub async fn listen(&self, config: Config<M, T>, tx: Sender<TreeChanged>) -> eyre::Result<()> 
    where 
        T: StarknetJsonRpcTransport + Send + Sync,
    {
        let event_name = "TreeChanged(uint256,uint8,uint256)";
        let filter = Filter::new()
            .address(config.world_address_book.worldid_router)
            .event(&TreeChanged::abi_signature());
        let l1_provider = self.config.get_l1_provider();

        let mut stream = l1_provider.subscribe_logs(&filter).await?;

        while let Some(log) = stream.next().await {

        }

        Ok(())
    }

    
}