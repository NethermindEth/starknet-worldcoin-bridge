use crate::config::config::Config;
use crate::telemetry::{
    config::TelemetryConfig,
    metrics::{BalanceHistory, BalanceSnapshot, Metrics},
};

use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::time::{Instant, SystemTime, UNIX_EPOCH};

use ethers::providers::Middleware;
use ethers::signers::Signer;
use ethers::types::U256;
use starknet::providers::jsonrpc::JsonRpcTransport as StarknetJsonRpcTransport;
use tokio::time::{interval, MissedTickBehavior};
use tracing::{debug, error, info, warn};

/// Minimum balance threshold in ETH - below this, an alert is triggered
const MIN_BALANCE_THRESHOLD_ETH: f64 = 0.01;

/// Critical balance threshold in ETH - below this, a critical alert is triggered
const CRITICAL_BALANCE_THRESHOLD_ETH: f64 = 0.001;

/// Balance monitoring service that continuously polls wallet balances
/// and updates telemetry metrics
pub struct BalanceMonitor<M, T>
where
    M: Middleware + 'static,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    config: Arc<Config<M, T>>,
    telemetry_config: TelemetryConfig,
    metrics: Metrics,
    balance_history: BalanceHistory,
    start_time: Instant,
    /// Track if we've already sent a low balance alert (to avoid spam)
    low_balance_alerted: AtomicBool,
    /// Track if we've already sent a critical balance alert
    critical_balance_alerted: AtomicBool,
}

impl<M, T> BalanceMonitor<M, T>
where
    M: Middleware + 'static,
    T: StarknetJsonRpcTransport + Send + Sync + 'static,
{
    /// Create a new balance monitor
    pub fn new(
        config: Arc<Config<M, T>>,
        telemetry_config: TelemetryConfig,
        metrics: Metrics,
    ) -> Self {
        let balance_history = BalanceHistory::new(telemetry_config.max_balance_history);
        let start_time = Instant::now();

        Self {
            config,
            telemetry_config,
            metrics,
            balance_history,
            start_time,
            low_balance_alerted: AtomicBool::new(false),
            critical_balance_alerted: AtomicBool::new(false),
        }
    }

    /// Start the balance monitoring service
    /// This runs indefinitely, polling balances at the configured interval
    pub async fn start(self: Arc<Self>) -> eyre::Result<()> {
        info!(
            "Starting balance monitor with {} second intervals",
            self.telemetry_config.balance_poll_interval.as_secs()
        );

        let mut interval_timer = interval(self.telemetry_config.balance_poll_interval);
        interval_timer.set_missed_tick_behavior(MissedTickBehavior::Skip);

        loop {
            interval_timer.tick().await;

            // Update service uptime
            let uptime = self.start_time.elapsed().as_secs() as f64;
            self.metrics.update_uptime(uptime);

            // Poll balances
            if let Err(e) = self.poll_balances().await {
                error!("Balance polling failed: {}", e);
            }
        }
    }

    /// Poll both L1 and L2 balances and update metrics
    async fn poll_balances(&self) -> eyre::Result<()> {
        let poll_start = Instant::now();

        debug!("Starting balance poll");

        // Poll L1 balance and gas price
        match self.get_l1_balance_and_gas().await {
            Ok((l1_balance, gas_price)) => {
                let poll_duration = poll_start.elapsed().as_secs_f64();

                // Convert balances to human-readable format
                let l1_balance_eth = wei_to_eth(l1_balance);
                let gas_price_gwei = gas_price.map(wei_to_gwei);

                // Check for low balance and send alerts
                self.check_balance_alerts(l1_balance_eth);

                // Update metrics
                self.metrics
                    .record_balance_poll_success(poll_duration, l1_balance_eth);

                if let Some(gp) = gas_price_gwei {
                    self.metrics.update_gas_price(gp);
                }

                // Store historical data
                let snapshot = BalanceSnapshot::new(l1_balance_eth, gas_price_gwei);
                self.balance_history.add_snapshot(snapshot).await;

                match gas_price_gwei {
                    Some(gp) => info!(
                        "Balance poll successful: L1={:.6} ETH, Gas={:.6} Gwei, Duration={:.3}s",
                        l1_balance_eth, gp, poll_duration
                    ),
                    None => info!(
                        "Balance poll successful: L1={:.6} ETH, Gas=FAILED, Duration={:.3}s",
                        l1_balance_eth, poll_duration
                    ),
                }
            }
            Err(e) => {
                let poll_duration = poll_start.elapsed().as_secs_f64();
                self.metrics.record_balance_poll_failure(poll_duration);
                error!("Balance poll failed after {:.3}s: {}", poll_duration, e);
                return Err(e);
            }
        }

        Ok(())
    }

    /// Check balance thresholds and send alerts if needed
    fn check_balance_alerts(&self, balance_eth: f64) {
        let wallet_address = self.config.wallet().address();

        // Critical balance alert (highest priority)
        if balance_eth < CRITICAL_BALANCE_THRESHOLD_ETH {
            // Only alert once until balance is restored
            if !self.critical_balance_alerted.swap(true, Ordering::SeqCst) {
                error!(
                    "CRITICAL: Relayer wallet balance is critically low! \
                     Balance: {:.6} ETH, Wallet: {:?}. \
                     Transactions will fail! Please fund the wallet immediately.",
                    balance_eth, wallet_address
                );
            }
            // Also ensure low balance alert is set
            self.low_balance_alerted.store(true, Ordering::SeqCst);
        }
        // Low balance warning
        else if balance_eth < MIN_BALANCE_THRESHOLD_ETH {
            // Reset critical alert if balance improved above critical
            if self.critical_balance_alerted.swap(false, Ordering::SeqCst) {
                info!("Balance improved above critical threshold");
            }

            // Only alert once until balance is restored
            if !self.low_balance_alerted.swap(true, Ordering::SeqCst) {
                error!(
                    "LOW BALANCE WARNING: Relayer wallet balance is low! \
                     Balance: {:.6} ETH, Wallet: {:?}. \
                     Recommended minimum: {} ETH. Please fund the wallet soon.",
                    balance_eth, wallet_address, MIN_BALANCE_THRESHOLD_ETH
                );
            }
        }
        // Balance is healthy - reset alerts
        else {
            let was_critical = self.critical_balance_alerted.swap(false, Ordering::SeqCst);
            let was_low = self.low_balance_alerted.swap(false, Ordering::SeqCst);

            if was_critical || was_low {
                info!(
                    "Balance restored to healthy level: {:.6} ETH",
                    balance_eth
                );
            }
        }
    }

    /// Get L1 (Ethereum) balance and current gas price
    async fn get_l1_balance_and_gas(&self) -> eyre::Result<(U256, Option<U256>)> {
        let wallet_address = self.config.wallet().address();

        debug!("Querying balance for wallet: {:?}", wallet_address);

        // Get balance and gas price concurrently
        let provider = self.config.l1_provider();
        let balance_future = provider.get_balance(wallet_address, None);
        let gas_price_future = provider.get_gas_price();

        let (balance_result, gas_price_result) = tokio::join!(balance_future, gas_price_future);

        let balance = balance_result.map_err(|e| {
            warn!("Failed to get L1 balance: {}", e);
            eyre::eyre!("L1 balance query failed: {}", e)
        })?;

        debug!("Raw balance from RPC: {} wei", balance);

        let gas_price = match gas_price_result {
            Ok(gp) => {
                Some(gp)
            }
            Err(e) => {
                error!("Failed to get gas price: {}", e);
                None
            }
        };

        debug!("L1 balance: {} wei ({} ETH)", balance, wei_to_eth(balance));

        Ok((balance, gas_price))
    }

    /// Get balance history for analysis
    pub async fn get_balance_history(&self, count: Option<usize>) -> Vec<BalanceSnapshot> {
        match count {
            Some(n) => self.balance_history.get_recent_snapshots(n).await,
            None => self.balance_history.get_all_snapshots().await,
        }
    }

    /// Get current balance summary
    pub async fn get_current_balance_summary(&self) -> eyre::Result<BalanceSummary> {
        let l1_result = self.get_l1_balance_and_gas().await?;
        let l1_balance = l1_result.0;

        Ok(BalanceSummary {
            l1_balance_eth: wei_to_eth(l1_balance),
            timestamp: SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        })
    }
}

/// Current balance summary
#[derive(Debug, Clone)]
pub struct BalanceSummary {
    pub l1_balance_eth: f64,
    pub timestamp: u64,
}

/// Convert Wei to ETH
fn wei_to_eth(wei: U256) -> f64 {
    // Convert U256 to string and parse to avoid precision issues with as_u128()
    let wei_str = wei.to_string();
    let wei_val: f64 = wei_str.parse().unwrap_or(0.0);
    wei_val / 1_000_000_000_000_000_000.0 // 10^18
}

/// Convert Wei to Gwei
fn wei_to_gwei(wei: U256) -> f64 {
    // Convert U256 to string and parse to avoid precision issues with as_u128()
    let wei_str = wei.to_string();
    let wei_val: f64 = wei_str.parse().unwrap_or(0.0);
    wei_val / 1_000_000_000.0 // 10^9
}
