use crate::abi::{self, TreeChanged};
use crate::config::bridge_config::BridgeConfig;
use crate::config::config::Config;
use crate::config::utils::into_felt;
use crate::config::{
    cli::Fee,
    constants::defaults::{
        CACHE_CLEAR_INTERVAL, CACHE_MAX_SIZE, CHANNEL_CAPACITY, DEFAULT_FEE, MAX_ESTIMATED_FEE_WEI,
        NO_FEE, POLL_INTERVAL, RECONNECT_BACKOFF_SECS, RECONNECT_POLL_DELAY,
    },
};
use crate::core::transaction::{self, check_gas_limit};
use crate::error::error::{StateBridgeError, TransactionError};
use crate::telemetry::{BalanceMonitor, Metrics, MetricsExporter, TelemetryConfig};

use std::collections::{HashSet, VecDeque};
use std::sync::Arc;
use std::time::{Duration, Instant as StdInstant};

use ethers::contract::EthEvent;
use ethers::providers::{Middleware, Provider, PubsubClient, StreamExt, Ws};
use ethers::signers::Signer;
use ethers::types::{Filter, U256};
use starknet::core::types::Felt;
use starknet::providers::jsonrpc::JsonRpcTransport as StarknetJsonRpcTransport;
use tokio::sync::mpsc;
use tokio::sync::mpsc::{Receiver, Sender};
use tokio::sync::Mutex;
use tokio::time::{sleep, Instant};
use tracing::{error, info, instrument, warn};

/// Configuration for WebSocket reconnection behavior
#[derive(Debug, Clone)]
pub struct ReconnectionConfig {
    /// Maximum number of reconnection attempts (0 = infinite)
    pub max_retries: usize,
    /// Backoff schedule for reconnect attempts
    pub backoff_schedule: Vec<Duration>,
}

impl Default for ReconnectionConfig {
    fn default() -> Self {
        let backoff_schedule = RECONNECT_BACKOFF_SECS
            .iter()
            .map(|secs| Duration::from_secs(*secs))
            .collect::<Vec<_>>();

        Self {
            max_retries: 0, // Infinite retries by default
            backoff_schedule,
        }
    }
}

struct RootCache {
    max_size: usize,
    clear_interval: Duration,
    last_clear_at: StdInstant,
    order: VecDeque<U256>,
    set: HashSet<U256>,
}

impl RootCache {
    fn new(max_size: usize, clear_interval: Duration) -> Self {
        Self {
            max_size,
            clear_interval,
            last_clear_at: StdInstant::now(),
            order: VecDeque::with_capacity(max_size),
            set: HashSet::with_capacity(max_size),
        }
    }

    fn maybe_clear(&mut self) {
        if self.last_clear_at.elapsed() >= self.clear_interval {
            self.order.clear();
            self.set.clear();
            self.last_clear_at = StdInstant::now();
        }
    }

    fn contains(&mut self, root: &U256) -> bool {
        self.maybe_clear();
        self.set.contains(root)
    }

    fn insert(&mut self, root: U256) {
        self.maybe_clear();
        if self.set.insert(root) {
            self.order.push_back(root);
            if self.order.len() > self.max_size {
                if let Some(evicted) = self.order.pop_front() {
                    self.set.remove(&evicted);
                }
            }
        }
    }
}

struct Backoff {
    delays: Vec<Duration>,
    idx: usize,
}

impl Backoff {
    fn new(delays: Vec<Duration>) -> Self {
        Self { delays, idx: 0 }
    }

    fn reset(&mut self) {
        self.idx = 0;
    }

    fn next_delay(&mut self) -> Duration {
        let delay = self
            .delays
            .get(self.idx)
            .copied()
            .unwrap_or_else(|| *self.delays.last().unwrap_or(&Duration::from_secs(20)));
        self.idx = self.idx.saturating_add(1);
        delay
    }
}

#[cfg(test)]
mod tests {
    use super::{compute_next_poll_deadline, Backoff, PollSignal, RootCache};
    use std::time::Duration;
    use ethers::types::U256;
    use tokio::time::Instant;

    #[test]
    fn root_cache_eviction() {
        let mut cache = RootCache::new(2, Duration::from_secs(3600));
        cache.insert(U256::from(1));
        cache.insert(U256::from(2));
        cache.insert(U256::from(3));

        assert!(!cache.contains(&U256::from(1)));
        assert!(cache.contains(&U256::from(2)));
        assert!(cache.contains(&U256::from(3)));
    }

    #[test]
    fn root_cache_clears_on_interval() {
        let mut cache = RootCache::new(2, Duration::from_secs(0));
        cache.insert(U256::from(1));
        assert!(!cache.contains(&U256::from(1)));
    }

    #[test]
    fn backoff_repeats_last_delay() {
        let mut backoff = Backoff::new(vec![
            Duration::from_secs(5),
            Duration::from_secs(10),
        ]);

        assert_eq!(backoff.next_delay(), Duration::from_secs(5));
        assert_eq!(backoff.next_delay(), Duration::from_secs(10));
        assert_eq!(backoff.next_delay(), Duration::from_secs(10));
    }

    #[test]
    fn poll_deadline_reset_and_expedite() {
        let now = Instant::now();
        let poll_interval = Duration::from_secs(60);
        let reconnect_delay = Duration::from_secs(5);
        let current_deadline = now + poll_interval;

        let reset_deadline = compute_next_poll_deadline(
            now,
            current_deadline,
            PollSignal::Reset,
            poll_interval,
            reconnect_delay,
        );
        assert_eq!(reset_deadline, now + poll_interval);

        let expedite_deadline = compute_next_poll_deadline(
            now,
            current_deadline,
            PollSignal::Expedite,
            poll_interval,
            reconnect_delay,
        );
        assert_eq!(expedite_deadline, now + reconnect_delay);
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
    cache: Arc<Mutex<RootCache>>,
}

pub(crate) struct QueuedEvent {
    event: TreeChanged,
    received_at: StdInstant,
}

pub enum PollSignal {
    Reset,
    Expedite,
}

pub fn compute_next_poll_deadline(
    now: Instant,
    current_deadline: Instant,
    signal: PollSignal,
    poll_interval: Duration,
    reconnect_delay: Duration,
) -> Instant {
    match signal {
        PollSignal::Reset => now + poll_interval,
        PollSignal::Expedite => {
            let expedite = now + reconnect_delay;
            if expedite < current_deadline {
                expedite
            } else {
                current_deadline
            }
        }
    }
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
            cache: Arc::new(Mutex::new(RootCache::new(
                CACHE_MAX_SIZE,
                CACHE_CLEAR_INTERVAL,
            ))),
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
            cache: Arc::new(Mutex::new(RootCache::new(
                CACHE_MAX_SIZE,
                CACHE_CLEAR_INTERVAL,
            ))),
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
        let tx_start = StdInstant::now();

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
                    gas_used = receipt.gas_used.map(|g| g.as_u64());
                    Ok(())
                }
                Err(e) => {
                    Err(StateBridgeError::TransactionError(e))
                }
            }
        } else {
            tracing::info!("Default gas limit exceeded");
            Err(StateBridgeError::GasLimitError(gas_limit))
        };

        // Record transaction metrics if telemetry is enabled
        if let Some(metrics) = &self.metrics {
            let tx_duration = tx_start.elapsed().as_secs_f64();
            metrics.record_transaction(result.is_ok(), gas_used, tx_duration);
        }

        result
    }

    async fn propagate_root_with_retry(&self, value: U256) -> Result<(), StateBridgeError<M>> {
        let mut attempts = 0;
        let retry_delays = [Duration::from_secs(1), Duration::from_secs(2)];

        loop {
            match self.propagate_root(value).await {
                Ok(()) => return Ok(()),
                Err(err) => {
                    if !is_fast_fail(&err) || attempts >= retry_delays.len() {
                        if matches!(
                            &err,
                            StateBridgeError::TransactionError(TransactionError::TxReceiptNotFound(_))
                        ) {
                            if let Some(metrics) = &self.metrics {
                                metrics.record_tx_receipt_failure();
                            }
                        }

                        if let Some(metrics) = &self.metrics {
                            record_tx_error(metrics, &err);
                        }

                        return Err(err);
                    }

                    if let Some(metrics) = &self.metrics {
                        metrics.record_tx_send_fail_fast();
                    }

                    let delay = retry_delays[attempts];
                    attempts += 1;
                    sleep(delay).await;
                }
            }
        }
    }

    fn fee_to_u256(fee: Felt) -> U256 {
        U256::from_big_endian(&fee.to_bytes_be())
    }

    fn cap_estimated_fee(fee: Felt) -> Felt {
        if fee > MAX_ESTIMATED_FEE_WEI {
            MAX_ESTIMATED_FEE_WEI
        } else {
            fee
        }
    }

    async fn get_and_compare_roots(&self) -> eyre::Result<()> {
        let (l1_root, l2_root) = self.fetch_roots().await?;

        if l1_root == l2_root {
            if let Some(metrics) = &self.metrics {
                metrics.record_poll_synced_roots();
            }
            return Ok(());
        }

        {
            let mut cache = self.cache.lock().await;
            cache.insert(l1_root);
        }

        if let Some(metrics) = &self.metrics {
            metrics.record_poll_unsynced_roots();
        }

        let root_as_felts = into_felt(l1_root)?;
        let fee = match self.config.fee_type {
            Fee::Default => DEFAULT_FEE,
            Fee::Estimate => {
                let estimated = self
                    .config
                    .estimate_messaging_fee(root_as_felts)
                    .await?
                    .overall_fee;
                Self::cap_estimated_fee(estimated)
            }
            Fee::NoFee => NO_FEE,
        };

        self.propagate_root_with_retry(Self::fee_to_u256(fee))
            .await?;

        Ok(())
    }

    pub async fn compare_roots(&self) -> eyre::Result<bool> {
        let (l1_root, l2_root) = self.fetch_roots().await?;
        Ok(l1_root == l2_root)
    }

    async fn fetch_roots(&self) -> eyre::Result<(U256, U256)> {
        let l1_root = self.config.get_l1_root_u256().await?;
        let l2_root = self.config.get_l2_root_u256().await?;

        if l1_root.is_zero() {
            eyre::bail!("L1 latest_root is zero");
        }

        if l2_root.is_zero() {
            eyre::bail!("L2 latest_root is zero");
        }

        Ok((l1_root, l2_root))
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

        let (tx, rx) = mpsc::channel::<QueuedEvent>(CHANNEL_CAPACITY);
        let (poll_tx, poll_rx) = mpsc::channel::<PollSignal>(CHANNEL_CAPACITY);

        let listener_handle = {
            let sb = self.clone();
            let poll_tx = poll_tx.clone();
            tokio::spawn(async move {
                if let Err(e) = sb.listen_with_reconnect(tx, poll_tx).await {
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

        let poller_handle = {
            let sb = self.clone();
            tokio::spawn(async move {
                if let Err(e) = sb.poller(poll_rx).await {
                    tracing::warn!("poller exited: {e:#}");
                }
            })
        };

        // Join all handles
        match balance_monitor_handle {
            Some(monitor_handle) => {
                tokio::try_join!(
                    listener_handle,
                    executor_handle,
                    poller_handle,
                    monitor_handle
                )?;
            }
            None => {
                tokio::try_join!(listener_handle, executor_handle, poller_handle)?;
            }
        }

        Ok(())
    }

    #[cfg(not(feature = "debug"))]
    pub(crate) async fn execute(
        self: Arc<Self>,
        mut rx: Receiver<QueuedEvent>,
    ) -> eyre::Result<()> {
        while let Some(queued) = rx.recv().await {
            if let Some(metrics) = &self.metrics {
                let elapsed = queued.received_at.elapsed().as_secs_f64();
                metrics.record_event_processing_latency(elapsed);
            }

            let root = into_felt(queued.event.post_root)?;

        let fee = match self.config.fee_type {
            Fee::Default => DEFAULT_FEE,
            Fee::Estimate => {
                let estimated = self.config.estimate_messaging_fee(root).await?.overall_fee;
                Self::cap_estimated_fee(estimated)
            }
            Fee::NoFee => NO_FEE,
        };

            if let Some(metrics) = &self.metrics {
                let fee_value = U256::from_big_endian(&fee.to_bytes_be());
                metrics.record_fee_value_wei(fee_value.as_u128() as f64);
            }

            self.propagate_root_with_retry(Self::fee_to_u256(fee))
                .await?;
        }

        Ok(())
    }

    async fn poller(self: Arc<Self>, mut poll_rx: Receiver<PollSignal>) -> eyre::Result<()> {
        let poll_interval = POLL_INTERVAL;
        let mut next_deadline = tokio::time::Instant::now() + poll_interval;

        loop {
            tokio::select! {
                _ = tokio::time::sleep_until(next_deadline) => {
                    if let Err(e) = self.get_and_compare_roots().await {
                        tracing::warn!("poller error: {e:#}");
                    }
                    next_deadline = tokio::time::Instant::now() + poll_interval;
                }
                signal = poll_rx.recv() => {
                    let now = tokio::time::Instant::now();
                    match signal {
                        Some(signal) => {
                            next_deadline = compute_next_poll_deadline(
                                now,
                                next_deadline,
                                signal,
                                poll_interval,
                                RECONNECT_POLL_DELAY,
                            );
                        }
                        None => break,
                    }
                }
            }
        }

        Ok(())
    }

    async fn connect_ws_provider(&self) -> eyre::Result<Provider<Ws>> {
        let primary = self.config.l1_ws_primary();
        match Ws::connect(primary).await {
            Ok(ws) => Ok(Provider::new(ws)),
            Err(primary_err) => {
                if let Some(fallback) = self.config.l1_ws_fallback() {
                    match Ws::connect(fallback).await {
                        Ok(ws) => Ok(Provider::new(ws)),
                        Err(fallback_err) => Err(eyre::eyre!(
                            "Primary WS failed: {primary_err}; fallback WS failed: {fallback_err}"
                        )),
                    }
                } else {
                    Err(primary_err.into())
                }
            }
        }
    }

    #[cfg(not(feature = "debug"))]
    fn event_filter(&self) -> Filter {
        Filter::new()
            .address(self.config.identity_manager())
            .event(&TreeChanged::abi_signature())
    }

    #[cfg(feature = "debug")]
    fn event_filter(&self) -> Filter {
        Filter::new()
            .address(self.config.identity_manager())
            .event(&TreeChanged::abi_signature())
            .from_block(8204458)
            .to_block(8204460)
    }

    /// Listen for events with automatic reconnection on failure
    pub(crate) async fn listen_with_reconnect(
        self: Arc<Self>,
        tx: Sender<QueuedEvent>,
        poll_tx: Sender<PollSignal>,
    ) -> eyre::Result<()> {
        let filter = self.event_filter();
        self.listen_internal(tx, poll_tx, filter).await
    }

    async fn listen_internal(
        self: Arc<Self>,
        tx: Sender<QueuedEvent>,
        poll_tx: Sender<PollSignal>,
        filter: Filter,
    ) -> eyre::Result<()> {
        let mut attempt = 0;
        let mut backoff = Backoff::new(self.reconnection_config.backoff_schedule.clone());

        // Initialize connection status
        if let Some(metrics) = &self.metrics {
            metrics.set_websocket_connected(false);
        }

        loop {
            attempt += 1;
            if let Some(metrics) = &self.metrics {
                metrics.record_websocket_connection_attempt();
            }

            let provider = match self.connect_ws_provider().await {
                Ok(provider) => {
                    if let Some(metrics) = &self.metrics {
                        metrics.record_websocket_connection_success();
                        metrics.set_websocket_connected(true);
                    }
                    let _ = poll_tx.send(PollSignal::Expedite).await;
                    backoff.reset();
                    provider
                }
                Err(e) => {
                    if let Some(metrics) = &self.metrics {
                        metrics.record_websocket_connection_failure();
                        metrics.set_websocket_connected(false);
                        metrics.record_websocket_backoff_retry();
                    }

                    if self.reconnection_config.max_retries > 0
                        && attempt > self.reconnection_config.max_retries
                    {
                        error!(
                            "Max reconnection attempts ({}) exceeded. Giving up.",
                            self.reconnection_config.max_retries
                        );
                        return Err(e);
                    }

                    let delay = backoff.next_delay();
                    warn!("WebSocket connection failed (attempt {}): {:#}", attempt, e);
                    info!("Waiting {} seconds before reconnection", delay.as_secs());
                    sleep(delay).await;
                    continue;
                }
            };

            let mut stream = match provider.subscribe_logs(&filter).await {
                Ok(stream) => stream,
                Err(e) => {
                    if let Some(metrics) = &self.metrics {
                        metrics.record_websocket_connection_failure();
                        metrics.set_websocket_connected(false);
                        metrics.record_websocket_backoff_retry();
                    }
                    let delay = backoff.next_delay();
                    warn!("WS subscribe failed: {e:#}");
                    info!("Waiting {} seconds before reconnection", delay.as_secs());
                    sleep(delay).await;
                    continue;
                }
            };

            while let Some(log) = stream.next().await {
                let _ = poll_tx.send(PollSignal::Reset).await;
                match TreeChanged::decode_log(&log.into()) {
                    Ok(evt) => {
                        let root = evt.post_root;
                        let mut cache = self.cache.lock().await;
                        if cache.contains(&root) {
                            if let Some(metrics) = &self.metrics {
                                metrics.record_event_cache_hit();
                            }
                            continue;
                        }

                        cache.insert(root);
                        if let Some(metrics) = &self.metrics {
                            metrics.record_event_cache_miss();
                        }
                        drop(cache);

                        let queued = QueuedEvent {
                            event: evt,
                            received_at: StdInstant::now(),
                        };

                        if let Err(e) = tx.send(queued).await {
                            warn!("Failed to send event to executor: {}", e);
                            return Ok(());
                        }
                    }
                    Err(e) => warn!("Failed to decode log as TreeChanged event: {:?}", e),
                }
            }

            if let Some(metrics) = &self.metrics {
                metrics.set_websocket_connected(false);
                metrics.record_websocket_disconnect();
                metrics.record_websocket_backoff_retry();
            }

            let delay = backoff.next_delay();
            info!("WebSocket disconnected, retrying in {} seconds", delay.as_secs());
            sleep(delay).await;
        }
    }

    #[cfg(feature = "debug")]
    #[instrument(skip(self, rx))]
    pub async fn execute(self: Arc<Self>, mut rx: Receiver<QueuedEvent>) -> eyre::Result<()> {
        while let Some(queued) = rx.recv().await {
            if let Some(metrics) = &self.metrics {
                let elapsed = queued.received_at.elapsed().as_secs_f64();
                metrics.record_event_processing_latency(elapsed);
            }

            println!("got = {:?}", queued.event);

            let root = into_felt(queued.event.post_root)?;

            let fee = match self.config.fee_type {
                Fee::Default => DEFAULT_FEE,
                Fee::Estimate => {
                    if root == self.config.get_root().await? {
                        tracing::info!("Latest Root Found, using dummy root for simumlation")
                    }

                    let dummy_root = self.config.get_root().await?;
                    let estimated = self
                        .config
                        .estimate_messaging_fee(dummy_root)
                        .await?
                        .overall_fee;

                    Self::cap_estimated_fee(estimated)
                }
                Fee::NoFee => NO_FEE,
            };

            if let Some(metrics) = &self.metrics {
                let fee_value = U256::from_big_endian(&fee.to_bytes_be());
                metrics.record_fee_value_wei(fee_value.as_u128() as f64);
            }

            self.propagate_root_with_retry(Self::fee_to_u256(fee))
                .await?;
        }

        Ok(())
    }

}

fn is_fast_fail<M: Middleware>(err: &StateBridgeError<M>) -> bool {
    matches!(
        err,
        StateBridgeError::ProviderError(_)
            | StateBridgeError::TransactionError(TransactionError::MiddlewareError(_))
            | StateBridgeError::TransactionError(TransactionError::ProviderError(_))
    )
}

fn record_tx_error<M: Middleware>(metrics: &Metrics, err: &StateBridgeError<M>) {
    match err {
        StateBridgeError::TransactionError(TransactionError::InsufficientWalletFunds) => {
            metrics.record_tx_error_insufficient_funds();
        }
        StateBridgeError::TransactionError(TransactionError::ProviderError(_))
        | StateBridgeError::ProviderError(_) => {
            metrics.record_tx_error_provider();
        }
        StateBridgeError::TransactionError(TransactionError::MiddlewareError(_)) => {
            metrics.record_tx_error_middleware();
        }
        StateBridgeError::GasLimitError(_) => {
            metrics.record_tx_error_gas_limit();
        }
        _ => {}
    }
}
