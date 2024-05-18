pub mod abi;
pub mod error;
//pub mod service;
pub mod transaction;

use std::ops::Sub;
use std::sync::Arc;

use ethers::providers::Middleware;
use ethers::signers::{LocalWallet, Signer};
use ethers::types::H160;
use ruint::Uint;
use tokio::select;
use tokio::task::JoinHandle;
use tokio::time::{Duration, Instant};
use tracing::instrument;

use self::error::StateBridgeError;

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

    /// Spawns a `StateBridge` task to listen for `TreeChanged` events from `WorldRoot` and propagate new roots.
    #[instrument(skip(self))]
    pub fn spawn(&self, value: u32) -> JoinHandle<Result<(), StateBridgeError<M>>> {
        let l1_state_bridge = self.l1_state_bridge;
        let relaying_period = self.relaying_period;
        let block_confirmations = self.block_confirmations;
        let wallet = self.wallet.clone();
        let l1_middleware = self.l1_middleware.clone();

        tracing::info!(
            ?l1_state_bridge,
            ?relaying_period,
            ?block_confirmations,
            "Spawning bridge"
        );

        tokio::spawn(async move {
            let mut last_propagation = Instant::now().sub(relaying_period);

            loop {
                // Sleep
                tokio::time::sleep(relaying_period).await;
                tracing::info!(?l1_state_bridge, "Sleep time elapsed");

                let time_since_last_propagation = Instant::now() - last_propagation;

                if time_since_last_propagation >= relaying_period {
                    tracing::info!(?l1_state_bridge, "Relaying period elapsed");

                    tracing::info!(?l1_state_bridge, "Propagating root");

                    Self::propagate_root(
                        l1_state_bridge,
                        &wallet,
                        block_confirmations,
                        l1_middleware.clone(),
                        value,
                    )
                    .await?;

                    last_propagation = Instant::now();
                }
            }
        })
    }

    pub async fn propagate_root(
        l1_state_bridge: H160,
        wallet: &LocalWallet,
        block_confirmations: usize,
        l1_middleware: Arc<M>,
        value: u32,
    ) -> Result<(), StateBridgeError<M>> {
        let calldata = abi::ISTATEBRIDGE_ABI
            .function("propagateRoot")?
            .encode_input(&[])?;

        let tx = transaction::fill_and_simulate_eip1559_transaction(
            calldata.into(),
            l1_state_bridge,
            wallet.address(),
            wallet.chain_id(),
            l1_middleware.clone(),
            value,
        )
        .await?;

        transaction::sign_and_send_transaction(tx, wallet, block_confirmations, l1_middleware)
            .await?;

        Ok(())
    }
}
