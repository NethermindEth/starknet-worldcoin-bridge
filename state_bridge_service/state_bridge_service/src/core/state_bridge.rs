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
use crate::telemetry::{BalanceMonitor, Metrics, MetricsExporter, TelemetryConfig};

use std::sync::Arc;
use std::time::{Duration, Instant};

use ethers::contract::EthEvent;
use ethers::providers::{Middleware, Provider as EthersProvider, PubsubClient, StreamExt, Ws};
use ethers::signers::Signer;
use ethers::types::{Filter, U256};
use starknet::providers::jsonrpc::JsonRpcTransport as StarknetJsonRpcTransport;
use tokio::sync::mpsc;
use tokio::sync::mpsc::{Receiver, Sender};
use tokio::time::sleep;
use tracing::{error, info, instrument, warn};

/// Configuration for WebSocket reconnection behavior
#[derive(Debug, Clone)]
pub struct ReconnectionConfig {
    /// Maximum number of reconnection attempts (0 = infinite)
    pub max_retries: usize,
    /// Initial delay between reconnection attempts
    pub initial_delay: Duration,
    /// Maximum delay between reconnection attempts
    pub max_delay: Duration,
    /// Multiplier for exponential backoff
    pub backoff_multiplier: f64,
    /// Timeout for connection attempts
    pub connection_timeout: Duration,
}

impl Default for ReconnectionConfig {
    fn default() -> Self {
        Self {
            max_retries: 0, // Infinite retries by default
            initial_delay: Duration::from_secs(1),
            max_delay: Duration::from_secs(60),
            backoff_multiplier: 2.0,
            connection_timeout: Duration::from_secs(30),
        }
    }
}

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
    reconnection_config: ReconnectionConfig,
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
            reconnection_config: Default::default(),
        })
    }

    pub fn from_config(config: impl Into<Arc<Config<M, T>>>) -> Result<Self, StateBridgeError<M>> {
        Ok(Self {
            config: config.into(),
            bridge_config: Default::default(),
            telemetry_config: None,
            metrics: None,
            _metrics_exporter: None,
            reconnection_config: Default::default(),
        })
    }

    /// Enable telemetry with the given configuration
    pub async fn with_telemetry(
        mut self,
        telemetry_config: TelemetryConfig,
    ) -> Result<Self, StateBridgeError<M>> {
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

    /// Configure reconnection behavior
    pub fn with_reconnection_config(mut self, config: ReconnectionConfig) -> Self {
        self.reconnection_config = config;
        self
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
            (&self.telemetry_config, &self.metrics)
        {
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
                if let Err(e) = sb.listen_with_reconnect(tx).await {
                    error!("listener exited permanently: {e:#}");
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

    /// Listen for events with automatic reconnection on failure
    pub async fn listen_with_reconnect(&self, tx: Sender<TreeChanged>) -> eyre::Result<()> {
        let mut attempt = 0;
        let mut delay = self.reconnection_config.initial_delay;

        // Initialize connection status
        if let Some(metrics) = &self.metrics {
            metrics.set_websocket_connected(false);
        }

        loop {
            // Record connection attempt
            if let Some(metrics) = &self.metrics {
                metrics.record_websocket_connection_attempt();
            }

            match self.listen_once(tx.clone()).await {
                Ok(_) => {
                    info!("Event listener completed normally");
                    if let Some(metrics) = &self.metrics {
                        metrics.set_websocket_connected(false);
                    }
                    break;
                }
                Err(e) => {
                    attempt += 1;

                    // Record connection failure
                    if let Some(metrics) = &self.metrics {
                        metrics.record_websocket_connection_failure();
                    }

                    // Check if we've exceeded max retries (0 means infinite)
                    if self.reconnection_config.max_retries > 0
                        && attempt > self.reconnection_config.max_retries
                    {
                        error!(
                            "Max reconnection attempts ({}) exceeded. Giving up.",
                            self.reconnection_config.max_retries
                        );
                        return Err(e);
                    }

                    warn!("WebSocket connection failed (attempt {}): {:#}", attempt, e);

                    // Check if this is a potentially recoverable error
                    if !self.is_recoverable_error(&e) {
                        error!("Non-recoverable error encountered: {:#}", e);
                        return Err(e);
                    }

                    info!(
                        "Waiting {} seconds before reconnection attempt {}",
                        delay.as_secs(),
                        attempt + 1
                    );
                    sleep(delay).await;

                    // Exponential backoff with jitter
                    delay = std::cmp::min(
                        Duration::from_secs_f64(
                            delay.as_secs_f64() * self.reconnection_config.backoff_multiplier,
                        ),
                        self.reconnection_config.max_delay,
                    );
                }
            }
        }

        Ok(())
    }

    /// Check if an error is potentially recoverable
    fn is_recoverable_error(&self, error: &eyre::Error) -> bool {
        let error_str = error.to_string().to_lowercase();

        // These are typically recoverable network/connection errors
        error_str.contains("connection")
            || error_str.contains("timeout")
            || error_str.contains("broken pipe")
            || error_str.contains("network")
            || error_str.contains("websocket")
            || error_str.contains("io error")
            || error_str.contains("transport")
    }

    /// Single attempt to listen for events (extracted from original listen method)
    #[cfg(not(feature = "debug"))]
    async fn listen_once(&self, tx: Sender<TreeChanged>) -> eyre::Result<()> {
        info!("Establishing WebSocket connection for event listening...");

        let filter = Filter::new()
            .address(self.config.identity_manager())
            .event(&TreeChanged::abi_signature());

        let l1_provider = self.config.l1_provider();

        let mut stream = l1_provider
            .subscribe_logs(&filter)
            .await
            .map_err(|e| eyre::eyre!("Failed to subscribe to logs: {}", e))?;

        // Record successful connection
        if let Some(metrics) = &self.metrics {
            metrics.record_websocket_connection_success();
        }

        info!(
            "WebSocket connection established, listening for TreeChanged events from {}",
            self.config.identity_manager()
        );

        while let Some(log) = stream.next().await {
            match TreeChanged::decode_log(&log.into()) {
                Ok(evt) => {
                    info!(
                        "Received TreeChanged event: pre_root={}, post_root={}, kind={}",
                        evt.pre_root, evt.post_root, evt.kind
                    );

                    if let Err(e) = tx.send(evt).await {
                        warn!("Failed to send event to executor: {}", e);
                        // Channel closed, likely shutting down
                        return Ok(());
                    }
                }
                Err(e) => warn!("Failed to decode log as TreeChanged event: {:?}", e),
            }
        }

        warn!("WebSocket stream ended unexpectedly");
        Err(eyre::eyre!("WebSocket stream closed"))
    }

    #[cfg(not(feature = "debug"))]
    pub async fn listen(&self, tx: Sender<TreeChanged>) -> eyre::Result<()> {
        self.listen_once(tx).await
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

    /// Single attempt to listen for events (debug version with specific block range)
    #[cfg(feature = "debug")]
    #[instrument(skip(self, tx))]
    async fn listen_once(&self, tx: Sender<TreeChanged>) -> eyre::Result<()> {
        info!("Establishing WebSocket connection for event listening (debug mode)...");

        let filter = Filter::new()
            .address(self.config.identity_manager())
            .event(&TreeChanged::abi_signature())
            .from_block(8204458)
            .to_block(8204460);

        let l1_provider = self.config.l1_provider();

        let mut stream = l1_provider
            .subscribe_logs(&filter)
            .await
            .map_err(|e| eyre::eyre!("Failed to subscribe to logs: {}", e))?;

        // Record successful connection
        if let Some(metrics) = &self.metrics {
            metrics.record_websocket_connection_success();
        }

        info!("WebSocket connection established (debug mode), listening for TreeChanged events from {} (blocks 8204458-8204460)", self.config.identity_manager());

        while let Some(log) = stream.next().await {
            match TreeChanged::decode_log(&log.into()) {
                Ok(evt) => {
                    info!(
                        "Received TreeChanged event (debug): pre_root={}, post_root={}, kind={}",
                        evt.pre_root, evt.post_root, evt.kind
                    );

                    if let Err(e) = tx.send(evt).await {
                        warn!("Failed to send event to executor: {}", e);
                        return Ok(());
                    }
                }
                Err(e) => warn!("Failed to decode log as TreeChanged event: {:?}", e),
            }
        }

        info!("Debug mode: finished processing block range");
        Ok(())
    }

    #[cfg(feature = "debug")]
    #[instrument(skip(self, tx))]
    pub async fn listen(&self, tx: Sender<TreeChanged>) -> eyre::Result<()> {
        self.listen_once(tx).await
    }
}
