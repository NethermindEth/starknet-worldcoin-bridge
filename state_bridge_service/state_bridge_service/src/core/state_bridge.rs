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

use std::collections::HashSet;
use std::sync::Arc;
use std::time::{Duration, Instant};

use ethers::contract::EthEvent;
use ethers::providers::{Middleware, PubsubClient, StreamExt};
use ethers::signers::Signer;
use ethers::types::{BlockNumber, Filter, U256};
use starknet::providers::jsonrpc::JsonRpcTransport as StarknetJsonRpcTransport;
use tokio::sync::{mpsc, RwLock};
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
    /// Cache of roots that have been successfully propagated (prevents duplicate attempts)
    propagated_roots: Arc<RwLock<HashSet<U256>>>,
    /// Last processed block number for catch-up after reconnection
    last_processed_block: Arc<RwLock<Option<u64>>>,
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
            propagated_roots: Arc::new(RwLock::new(HashSet::new())),
            last_processed_block: Arc::new(RwLock::new(None)),
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
            propagated_roots: Arc::new(RwLock::new(HashSet::new())),
            last_processed_block: Arc::new(RwLock::new(None)),
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

        // Increased buffer size from 1 to 32 to prevent event loss during slow processing
        let (tx, rx) = mpsc::channel::<TreeChanged>(32);

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
            // Check local cache first (covers roots we've propagated this session)
            {
                let cache = self.propagated_roots.read().await;
                if cache.contains(&evt.post_root) {
                    info!(
                        "Root {} already propagated (from cache), skipping",
                        evt.post_root
                    );
                    continue;
                }
            }

            // Check if this root already exists on L2 to avoid CANNOT_OVERWRITE_ROOT error
            let root_felt = match into_felt(evt.post_root) {
                Ok(r) => r,
                Err(e) => {
                    error!("Failed to convert root to felt: {:#}", e);
                    continue;
                }
            };

            // Check L2 for existing root (checks latest_root)
            if let Ok(true) = self.config.root_exists_on_l2(evt.post_root).await {
                info!(
                    "Root {} already exists on L2 (is latest), skipping propagation",
                    evt.post_root
                );
                // Add to cache so we don't check L2 again
                self.propagated_roots.write().await.insert(evt.post_root);
                continue;
            }

            // Estimate fee with retry logic
            let fee = match self.config.fee_type {
                Fee::Default => DEFAULT_FEE,
                Fee::Estimate => {
                    match self.estimate_fee_with_retry(root_felt.clone(), 3).await {
                        Ok(fee) => fee,
                        Err(e) => {
                            error!("Failed to estimate fee after retries: {:#}, using default", e);
                            DEFAULT_FEE
                        }
                    }
                }
                Fee::NoFee => NO_FEE,
            };

            // Propagate root with error handling - don't exit on failure
            match self.propagate_root(fee.to_bytes_be().into()).await {
                Ok(()) => {
                    info!("Successfully propagated root {}", evt.post_root);
                    // Add to cache on success
                    self.propagated_roots.write().await.insert(evt.post_root);
                }
                Err(e) => {
                    // Check if error is due to duplicate root (already propagated)
                    let error_str = format!("{:#}", e);
                    if error_str.contains("CANNOT_OVERWRITE_ROOT")
                        || error_str.contains("already exists")
                    {
                        info!("Root {} already exists on L2, skipping", evt.post_root);
                        // Add to cache so we don't try again
                        self.propagated_roots.write().await.insert(evt.post_root);
                    } else {
                        error!(
                            "Failed to propagate root {}: {:#}, continuing with next event",
                            evt.post_root, e
                        );
                    }
                    // Continue processing next events instead of exiting
                }
            }
        }

        Ok(())
    }

    /// Estimate messaging fee with retry logic
    async fn estimate_fee_with_retry(
        &self,
        root: Vec<starknet::core::types::Felt>,
        max_retries: u32,
    ) -> eyre::Result<starknet::core::types::Felt> {
        let mut last_error = None;
        let mut delay = Duration::from_millis(500);

        for attempt in 0..max_retries {
            match self.config.estimate_messaging_fee(root.clone()).await {
                Ok(fee) => return Ok(fee.overall_fee),
                Err(e) => {
                    warn!(
                        "Fee estimation attempt {}/{} failed: {:#}",
                        attempt + 1,
                        max_retries,
                        e
                    );
                    last_error = Some(e);
                    if attempt < max_retries - 1 {
                        sleep(delay).await;
                        delay = std::cmp::min(delay * 2, Duration::from_secs(5));
                    }
                }
            }
        }

        Err(last_error.unwrap_or_else(|| eyre::eyre!("Fee estimation failed")))
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

            // On reconnection (attempt > 0), catch up on missed events first
            if attempt > 0 {
                if let Err(e) = self.catch_up_missed_events(tx.clone()).await {
                    warn!("Failed to catch up on missed events: {:#}", e);
                    // Continue anyway - we'll try to listen for new events
                }
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

    /// Catch up on any events that may have been missed during disconnection
    async fn catch_up_missed_events(&self, tx: Sender<TreeChanged>) -> eyre::Result<()> {
        let last_block = {
            let guard = self.last_processed_block.read().await;
            *guard
        };

        let Some(from_block) = last_block else {
            info!("No previous block recorded, skipping catch-up");
            return Ok(());
        };

        // Get current block
        let current_block = self
            .config
            .l1_provider()
            .get_block_number()
            .await
            .map_err(|e| eyre::eyre!("Failed to get current block: {}", e))?
            .as_u64();

        if from_block >= current_block {
            info!("Already caught up to block {}", current_block);
            return Ok(());
        }

        info!(
            "Catching up on missed events from block {} to {}",
            from_block + 1,
            current_block
        );

        // Query historical logs
        let filter = Filter::new()
            .address(self.config.identity_manager())
            .event(&TreeChanged::abi_signature())
            .from_block(BlockNumber::Number((from_block + 1).into()))
            .to_block(BlockNumber::Number(current_block.into()));

        let logs = self
            .config
            .l1_provider()
            .get_logs(&filter)
            .await
            .map_err(|e| eyre::eyre!("Failed to fetch historical logs: {}", e))?;

        let missed_count = logs.len();
        if missed_count > 0 {
            info!("Found {} missed events during disconnection", missed_count);
        }

        for log in logs {
            match TreeChanged::decode_log(&log.into()) {
                Ok(evt) => {
                    info!(
                        "Processing missed TreeChanged event: pre_root={}, post_root={}, kind={}",
                        evt.pre_root, evt.post_root, evt.kind
                    );

                    if let Err(e) = tx.send(evt).await {
                        warn!("Failed to send caught-up event to executor: {}", e);
                        return Ok(());
                    }
                }
                Err(e) => warn!("Failed to decode historical log as TreeChanged event: {:?}", e),
            }
        }

        // Update last processed block
        {
            let mut guard = self.last_processed_block.write().await;
            *guard = Some(current_block);
        }

        if missed_count > 0 {
            info!("Catch-up complete, processed {} missed events", missed_count);
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

        // Get current block number to start tracking from
        let current_block = self
            .config
            .l1_provider()
            .get_block_number()
            .await
            .map_err(|e| eyre::eyre!("Failed to get current block: {}", e))?
            .as_u64();

        // Initialize last processed block if not set
        {
            let mut guard = self.last_processed_block.write().await;
            if guard.is_none() {
                *guard = Some(current_block);
                info!("Initialized block tracking at block {}", current_block);
            }
        }

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
            // Track block number for catch-up on reconnection
            if let Some(block_num) = log.block_number {
                let mut guard = self.last_processed_block.write().await;
                *guard = Some(block_num.as_u64());
            }

            match TreeChanged::decode_log(&log.clone().into()) {
                Ok(evt) => {
                    info!(
                        "Received TreeChanged event: pre_root={}, post_root={}, kind={}, block={}",
                        evt.pre_root, evt.post_root, evt.kind,
                        log.block_number.map(|b| b.as_u64()).unwrap_or(0)
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

            // Check local cache first
            {
                let cache = self.propagated_roots.read().await;
                if cache.contains(&evt.post_root) {
                    info!(
                        "Root {} already propagated (from cache), skipping",
                        evt.post_root
                    );
                    continue;
                }
            }

            let root = match into_felt(evt.post_root) {
                Ok(r) => r,
                Err(e) => {
                    error!("Failed to convert root to felt: {:#}", e);
                    continue;
                }
            };

            // Check if root already exists on L2
            if let Ok(true) = self.config.root_exists_on_l2(evt.post_root).await {
                info!(
                    "Root {} already exists on L2, skipping propagation",
                    evt.post_root
                );
                self.propagated_roots.write().await.insert(evt.post_root);
                continue;
            }

            let fee = match self.config.fee_type {
                Fee::Default => DEFAULT_FEE,
                Fee::Estimate => {
                    if root == self.config.get_root().await.unwrap_or_default() {
                        tracing::info!("Latest Root Found, using dummy root for simulation")
                    }

                    let dummy_root = match self.config.get_root().await {
                        Ok(r) => r,
                        Err(e) => {
                            error!("Failed to get root: {:#}, using default fee", e);
                            return Ok(());
                        }
                    };

                    match self.config.estimate_messaging_fee(dummy_root).await {
                        Ok(fee) => fee.overall_fee,
                        Err(e) => {
                            error!("Failed to estimate fee: {:#}, using default", e);
                            DEFAULT_FEE
                        }
                    }
                }
                Fee::NoFee => NO_FEE,
            };

            // Propagate root with error handling - don't exit on failure
            match self.propagate_root(fee.to_bytes_be().into()).await {
                Ok(()) => {
                    info!("Successfully propagated root {}", evt.post_root);
                    self.propagated_roots.write().await.insert(evt.post_root);
                }
                Err(e) => {
                    let error_str = format!("{:#}", e);
                    if error_str.contains("CANNOT_OVERWRITE_ROOT")
                        || error_str.contains("already exists")
                    {
                        info!("Root {} already exists on L2, skipping", evt.post_root);
                        self.propagated_roots.write().await.insert(evt.post_root);
                    } else {
                        error!(
                            "Failed to propagate root {}: {:#}, continuing with next event",
                            evt.post_root, e
                        );
                    }
                }
            }
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
