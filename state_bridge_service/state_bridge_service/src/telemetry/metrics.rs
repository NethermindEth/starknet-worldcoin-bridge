use metrics::{Counter, Gauge, Histogram};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tokio::sync::RwLock;

/// Core metrics collection for the State Bridge Service
#[derive(Clone)]
pub struct Metrics {
    /// Current L1 wallet balance in ETH
    pub l1_balance: Gauge,

    /// Number of successful balance polling operations
    pub balance_polls_success: Counter,

    /// Number of failed balance polling operations
    pub balance_polls_failed: Counter,

    /// Time taken to poll balance (in seconds)
    pub balance_poll_duration: Histogram,

    /// Current gas price on L1
    pub l1_gas_price: Gauge,

    /// Number of transactions sent
    pub transactions_sent: Counter,

    /// Number of successful transactions
    pub transactions_successful: Counter,

    /// Number of failed transactions
    pub transactions_failed: Counter,

    /// Gas used by transactions
    pub gas_used: Histogram,

    /// Transaction execution time
    pub transaction_duration: Histogram,

    /// Service uptime in seconds
    pub service_uptime: Gauge,

    /// Last successful balance update timestamp
    pub last_balance_update: Gauge,

    /// WebSocket connection attempts
    pub websocket_connections_attempted: Counter,

    /// WebSocket connection successes
    pub websocket_connections_successful: Counter,

    /// WebSocket connection failures
    pub websocket_connections_failed: Counter,

    /// Current WebSocket connection status (1 = connected, 0 = disconnected)
    pub websocket_connection_status: Gauge,
}

impl Metrics {
    /// Create a new metrics instance with all metrics registered
    pub fn new() -> Self {
        Self {
            l1_balance: metrics::gauge!("state_bridge_l1_balance_eth"),
            balance_polls_success: metrics::counter!("state_bridge_balance_polls_success_total"),
            balance_polls_failed: metrics::counter!("state_bridge_balance_polls_failed_total"),
            balance_poll_duration: metrics::histogram!(
                "state_bridge_balance_poll_duration_seconds"
            ),
            l1_gas_price: metrics::gauge!("state_bridge_l1_gas_price_gwei"),
            transactions_sent: metrics::counter!("state_bridge_transactions_sent_total"),
            transactions_successful: metrics::counter!(
                "state_bridge_transactions_successful_total"
            ),
            transactions_failed: metrics::counter!("state_bridge_transactions_failed_total"),
            gas_used: metrics::histogram!("state_bridge_gas_used"),
            transaction_duration: metrics::histogram!("state_bridge_transaction_duration_seconds"),
            service_uptime: metrics::gauge!("state_bridge_service_uptime_seconds"),
            last_balance_update: metrics::gauge!("state_bridge_last_balance_update_timestamp"),
            websocket_connections_attempted: metrics::counter!(
                "state_bridge_websocket_connections_attempted_total"
            ),
            websocket_connections_successful: metrics::counter!(
                "state_bridge_websocket_connections_successful_total"
            ),
            websocket_connections_failed: metrics::counter!(
                "state_bridge_websocket_connections_failed_total"
            ),
            websocket_connection_status: metrics::gauge!(
                "state_bridge_websocket_connection_status"
            ),
        }
    }

    /// Record a successful balance poll
    pub fn record_balance_poll_success(&self, duration_secs: f64, l1_balance: f64) {
        self.balance_polls_success.increment(1);
        self.balance_poll_duration.record(duration_secs);
        self.l1_balance.set(l1_balance);
        self.last_balance_update.set(
            SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_secs() as f64,
        );
    }

    /// Record a failed balance poll
    pub fn record_balance_poll_failure(&self, duration_secs: f64) {
        self.balance_polls_failed.increment(1);
        self.balance_poll_duration.record(duration_secs);
    }

    /// Record transaction metrics
    pub fn record_transaction(&self, success: bool, gas_used: Option<u64>, duration_secs: f64) {
        self.transactions_sent.increment(1);
        self.transaction_duration.record(duration_secs);

        if success {
            self.transactions_successful.increment(1);
        } else {
            self.transactions_failed.increment(1);
        }

        if let Some(gas) = gas_used {
            self.gas_used.record(gas as f64);
        }
    }

    /// Update gas price
    pub fn update_gas_price(&self, gas_price_gwei: f64) {
        self.l1_gas_price.set(gas_price_gwei);
    }

    /// Update service uptime
    pub fn update_uptime(&self, uptime_secs: f64) {
        self.service_uptime.set(uptime_secs);
    }

    /// Record WebSocket connection attempt
    pub fn record_websocket_connection_attempt(&self) {
        self.websocket_connections_attempted.increment(1);
    }

    /// Record successful WebSocket connection
    pub fn record_websocket_connection_success(&self) {
        self.websocket_connections_successful.increment(1);
        self.websocket_connection_status.set(1.0);
    }

    /// Record failed WebSocket connection
    pub fn record_websocket_connection_failure(&self) {
        self.websocket_connections_failed.increment(1);
        self.websocket_connection_status.set(0.0);
    }

    /// Update WebSocket connection status
    pub fn set_websocket_connected(&self, connected: bool) {
        self.websocket_connection_status
            .set(if connected { 1.0 } else { 0.0 });
    }
}

/// Historical balance data for trending analysis
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BalanceSnapshot {
    pub timestamp: u64,
    pub l1_balance_eth: f64,
    pub l1_gas_price_gwei: Option<f64>,
}

impl BalanceSnapshot {
    pub fn new(l1_balance: f64, gas_price: Option<f64>) -> Self {
        Self {
            timestamp: SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            l1_balance_eth: l1_balance,
            l1_gas_price_gwei: gas_price,
        }
    }
}

/// Historical balance tracking
#[derive(Debug)]
pub struct BalanceHistory {
    snapshots: Arc<RwLock<Vec<BalanceSnapshot>>>,
    max_size: usize,
}

impl BalanceHistory {
    pub fn new(max_size: usize) -> Self {
        Self {
            snapshots: Arc::new(RwLock::new(Vec::new())),
            max_size,
        }
    }

    pub async fn add_snapshot(&self, snapshot: BalanceSnapshot) {
        let mut snapshots = self.snapshots.write().await;
        snapshots.push(snapshot);

        // Keep only the most recent snapshots
        if snapshots.len() > self.max_size {
            snapshots.remove(0);
        }
    }

    pub async fn get_recent_snapshots(&self, count: usize) -> Vec<BalanceSnapshot> {
        let snapshots = self.snapshots.read().await;
        let start_idx = if snapshots.len() > count {
            snapshots.len() - count
        } else {
            0
        };
        snapshots[start_idx..].to_vec()
    }

    pub async fn get_all_snapshots(&self) -> Vec<BalanceSnapshot> {
        self.snapshots.read().await.clone()
    }
}
