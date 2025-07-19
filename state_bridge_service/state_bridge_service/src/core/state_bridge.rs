use crate::abi::{self, TreeChanged};
use crate::config::bridge_config::BridgeConfig;
use crate::config::config::Config;
use crate::config::utils::into_felt;
use crate::config::{
    cli::Fee,
    constants::defaults::{DEFAULT_FEE, NO_FEE},
};
use crate::core::transaction::{self, check_gas_limit};
use crate::error::error::StateBridgeError;
use crate::telemetry::{
    BalanceMonitor, Metrics, MetricsExporter, TelemetryConfig,
};

use std::sync::Arc;
use std::time::Instant;

use ethers::contract::EthEvent;
use ethers::providers::{Middleware, PubsubClient, StreamExt};
use ethers::signers::Signer;
use ethers::types::{Filter, U256};
use starknet::providers::jsonrpc::JsonRpcTransport as StarknetJsonRpcTransport;
use tokio::sync::mpsc;
use tokio::sync::mpsc::{Receiver, Sender};
use tracing::instrument;

/// The `StateBridge` is responsible for monitoring root changes from the `WorldRoot`, and calling the root propogation
pub struct StateBridge<M: Middleware + 'static, T>
where
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    config: Arc<Config<M, T>>,
    bridge_config: BridgeConfig,
    telemetry_config: Option<TelemetryConfig>,
    metrics: Option<Metrics>,
    _metrics_exporter: Option<MetricsExporter>,
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
    pub fn new(config: impl Into<Arc<Config<M, T>>>) -> Result<Self, StateBridgeError<M>> {
        Ok(Self {
            config: config.into(),
            bridge_config: Default::default(),
            telemetry_config: None,
            metrics: None,
            _metrics_exporter: None,
        })
    }

    pub fn from_config(config: impl Into<Arc<Config<M, T>>>) -> Result<Self, StateBridgeError<M>> {
        Ok(Self {
            config: config.into(),
            bridge_config: Default::default(),
            telemetry_config: None,
            metrics: None,
            _metrics_exporter: None,
        })
    }

    /// Enable telemetry with the given configuration
    pub async fn with_telemetry(mut self, telemetry_config: TelemetryConfig) -> Result<Self, StateBridgeError<M>> {
        match crate::telemetry::init_telemetry(telemetry_config.clone()).await {
            Ok((exporter, metrics)) => {
                self.telemetry_config = Some(telemetry_config);
                self.metrics = Some(metrics);
                self._metrics_exporter = Some(exporter);
                tracing::info!("Telemetry enabled successfully");
                Ok(self)
            }
            Err(e) => {
                tracing::error!("Failed to initialize telemetry: {}", e);
                Err(StateBridgeError::TelemetryInitError(e.to_string()))
            }
        }
    }

    #[instrument(skip(self))]
    pub async fn propagate_root(&self, value: U256) -> Result<(), StateBridgeError<M>> {
        let tx_start = Instant::now();

        let calldata = abi::abi::ISTATEBRIDGE_ABI
            .function("propagateRoot")?
            .encode_input(&[])?;

        let tx = transaction::fill_and_simulate_eip1559_transaction(
            calldata.into(),
            self.config.l1_bridge_address(),
            self.config.wallet().address(),
            self.config.wallet().chain_id(),
            self.config.l1_provider(),
            value,
        )
        .await?;

        let gas_limit = *tx.gas().unwrap();
        let mut transaction_success = false;
        let mut gas_used: Option<u64> = None;

        let result = if check_gas_limit(gas_limit) {
            match transaction::sign_and_send_transaction(
                tx,
                &self.config.wallet(),
                self.bridge_config.block_confirmations,
                self.config.l1_provider(),
            )
            .await
            {
                Ok(receipt) => {
                    transaction_success = true;
                    gas_used = receipt.gas_used.map(|g| g.as_u64());
                    Ok(())
                }
                Err(e) => {
                    transaction_success = false;
                    Err(StateBridgeError::TransactionError(e))
                }
            }
        } else {
            tracing::info!("Default gas limit exceeded");
            transaction_success = false;
            Err(StateBridgeError::GasLimitError(gas_limit))
        };

        // Record transaction metrics if telemetry is enabled
        if let Some(metrics) = &self.metrics {
            let tx_duration = tx_start.elapsed().as_secs_f64();
            metrics.record_transaction(transaction_success, gas_used, tx_duration);
        }

        result
    }
}

impl<M, T> StateBridge<M, T>
where
    M: Middleware + 'static,
    <M as Middleware>::Provider: PubsubClient,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    // Start bounded channel
    pub async fn start(self: Arc<Self>) -> eyre::Result<()>
    where
        T: StarknetJsonRpcTransport + Send + Sync,
    {
        // Start balance monitoring if telemetry is enabled
        let balance_monitor_handle = if let (Some(telemetry_config), Some(metrics)) = 
            (&self.telemetry_config, &self.metrics) {
            let balance_monitor = Arc::new(BalanceMonitor::new(
                self.config.clone(),
                telemetry_config.clone(),
                metrics.clone(),
            ));
            
            let monitor = balance_monitor.clone();
            Some(tokio::spawn(async move {
                if let Err(e) = monitor.start().await {
                    tracing::error!("Balance monitor exited: {:#}", e);
                }
            }))
        } else {
            None
        };

        let (tx, rx) = mpsc::channel::<TreeChanged>(1);

        let listener_handle = {
            let sb = self.clone();
            tokio::spawn(async move {
                if let Err(e) = sb.listen(tx).await {
                    tracing::warn!("listener exited: {e:#}");
                }
            })
        };

        let executor_handle = {
            let sb = self.clone();
            tokio::spawn(async move {
                if let Err(e) = sb.execute(rx).await {
                    tracing::warn!("executor exited: {e:#}");
                }
            })
        };

        // Join all handles
        match balance_monitor_handle {
            Some(monitor_handle) => {
                tokio::try_join!(listener_handle, executor_handle, monitor_handle)?;
            }
            None => {
        tokio::try_join!(listener_handle, executor_handle)?;
            }
        }

        Ok(())
    }

    #[cfg(not(feature = "debug"))]
    pub async fn execute(self: Arc<Self>, mut rx: Receiver<TreeChanged>) -> eyre::Result<()> {
        while let Some(evt) = rx.recv().await {
            let root = into_felt(evt.post_root)?;

            let fee = match self.config.fee_type {
                Fee::Default => DEFAULT_FEE,
                Fee::Estimate => self.config.estimate_messaging_fee(root).await?.overall_fee,
                Fee::NoFee => NO_FEE,
            };

            self.propagate_root(fee.to_bytes_be().into()).await?;
        }

        Ok(())
    }

    #[cfg(not(feature = "debug"))]
    pub async fn listen(&self, tx: Sender<TreeChanged>) -> eyre::Result<()> {
        let filter = Filter::new()
            .address(self.config.identity_manager())
            .event(&TreeChanged::abi_signature());

        let l1_provider = self.config.l1_provider();

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

    #[cfg(feature = "debug")]
    #[instrument(skip(self, rx))]
    pub async fn execute(self: Arc<Self>, mut rx: Receiver<TreeChanged>) -> eyre::Result<()> {
        while let Some(evt) = rx.recv().await {
            println!("got = {:?}", evt);

            let root = into_felt(evt.post_root)?;

            let fee = match self.config.fee_type {
                Fee::Default => DEFAULT_FEE,
                Fee::Estimate => {
                    if root == self.config.get_root().await? {
                        tracing::info!("Latest Root Found, using dummy root for simumlation")
                    }

                    let dummy_root = self.config.get_root().await?;

                    self.config
                        .estimate_messaging_fee(dummy_root)
                        .await?
                        .overall_fee
                }
                Fee::NoFee => NO_FEE,
            };

            self.propagate_root(fee.to_bytes_be().into()).await?;
        }

        Ok(())
    }

    #[cfg(feature = "debug")]
    #[instrument(skip(self, tx))]
    pub async fn listen(&self, tx: Sender<TreeChanged>) -> eyre::Result<()> {
        let filter = Filter::new()
            .address(self.config.identity_manager())
            .event(&TreeChanged::abi_signature())
            .from_block(8204458)
            .to_block(8204460);

        let l1_provider = self.config.l1_provider();

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
}
