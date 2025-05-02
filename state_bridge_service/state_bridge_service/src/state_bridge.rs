use crate::abi;
use crate::config::config::Config;
use crate::error::error::StateBridgeError;
use crate::transaction::{self, check_gas_limit};

use std::sync::Arc;

use ethers::providers::{Middleware, StreamExt};
use ethers::signers::{LocalWallet, Signer};
use ethers::types::{Filter, H160, U256};
use starknet::providers::jsonrpc::JsonRpcTransport as StarknetJsonRpcTransport;

use tokio::task::JoinHandle;
use tokio::time::{Duration, Instant};
use tracing::instrument;

//use crate::tree::Hash;

/// The `StateBridge` is responsible for monitoring root changes from the `WorldRoot`, and calling the root propogation
pub struct StateBridge<M: Middleware + 'static> {
    // Address for the state bridge contract on layer 1
    l1_state_bridge: H160,
    // Wallet responsible for sending `propagateRoot` transactions
    wallet: LocalWallet,
    // Middleware to interact with layer 1
    l1_middleware: Arc<M>,
    /// Time delay between `propagateRoot()` transactions
    pub relaying_period: Duration,
    /// The number of block confirmations before a `propagateRoot()` transaction is considered finalized
    pub block_confirmations: usize,
}

impl<M: Middleware> StateBridge<M> {
    /// # Arguments
    ///
    /// * l1_state_bridge - Address for the state bridge contract on layer 1.
    /// * wallet - Wallet responsible for sending `propagateRoot` transactions.
    /// * l1_middleware - Middleware to interact with layer 1.
    /// * relaying_period - Duration between successive propagateRoot() invocations.
    /// * block_confirmations - Number of block confirmations required to consider a propagateRoot() transaction as finalized.
    pub fn new(
        l1_state_bridge: H160,
        wallet: LocalWallet,
        l1_middleware: Arc<M>,
        relaying_period: Duration,
        block_confirmations: usize,
    ) -> Result<Self, StateBridgeError<M>> {
        Ok(Self {
            l1_state_bridge,
            wallet,
            l1_middleware,
            relaying_period,
            block_confirmations,
        })
    }

    pub fn from_config<T>(
        config: Config<M, T>,
        relaying_period: Duration,
        block_confirmations: usize,
    ) -> Result<Self, StateBridgeError<M>>
    where
        T: StarknetJsonRpcTransport + Send + Sync + 'static,
    {
        Ok(Self {
            l1_state_bridge: config.bridge_address_book.bridge_l1,
            wallet: config.owner,
            l1_middleware: config.l1_provider,
            relaying_period,
            block_confirmations,
        })
    }

    // todo: separate into tokio tasks
    pub async fn watch_and_execute<T>(&self, config: Config<M, T>) -> eyre::Result<()>
    where
        T: StarknetJsonRpcTransport + Send + Sync + 'static,
    {
        let fee = config.get_fee().await?;

        // Filter Events
        let event_name = "TreeChanged(uint256,uint8,uint256)";
        let filter = Filter::new()
            .address(config.world_address_book.worldid_router)
            .event(event_name);

        // New State Bridge Service
        let state_bridge =
            StateBridge::from_config(config, self.relaying_period, self.block_confirmations)?;

        // Event based root propogation
        let mut stream = self.l1_middleware.watch(&filter).await?.stream();

        while let log = stream.next().await {
            match log {
                Some(log) => {
                    let res = state_bridge.propagate_root(fee.to_bytes_be().into()).await;

                    match res {
                        Ok(()) => println!("ok"),
                        Err(e) => println!("error: {:?}", e),
                    }

                    println!("Event detected: {:?}", log);
                }
                None => {
                    eprintln!("Error listening to events");
                }
            }
        }

        // Single call rootPropogate()
        // let res = StateBridge::propagate_root(
        //     l1_state_bridge,
        //     &test_wallet,
        //     block_confirmations,
        //     provider.clone(),
        //     DEFAULT_GAS,
        // )
        // .await;

        // match res {
        //     Ok(()) => println!("ok"),
        //     Err(e) => println!("error: {:?}", e),
        // }

        // Interval Based Root Propagation
        // let join_handle = state_bridge.spawn(DEFAULT_GAS);

        // match join_handle.await {
        //     Ok(Ok(result)) => println!("Task result: {:?}", result),
        //     Ok(Err(e)) => eprintln!("Task error: {}", e),
        //     Err(e) => eprintln!("Join error: {:?}", e),
        // }

        Ok(())
    }
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
            self.l1_state_bridge,
            self.wallet.address(),
            self.wallet.chain_id(),
            self.l1_middleware.clone(),
            value,
        )
        .await?;

        let set_gas_limit = *tx.gas().unwrap();
        if check_gas_limit(set_gas_limit) {
            transaction::sign_and_send_transaction(
                tx,
                &self.wallet,
                self.block_confirmations,
                self.l1_middleware.clone(),
            )
            .await?;
        } else {
            tracing::info!("Default gas limit exceeded");
            return Err(StateBridgeError::GasLimitError(set_gas_limit));
        }

        Ok(())
    }
}
