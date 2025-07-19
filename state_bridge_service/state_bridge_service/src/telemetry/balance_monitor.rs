use crate::config::config::Config;
use crate::telemetry::{
    config::TelemetryConfig,
    metrics::{BalanceHistory, BalanceSnapshot, Metrics},
};

use std::sync::Arc;
use std::time::{Instant, SystemTime, UNIX_EPOCH};

use ethers::providers::Middleware;
use ethers::signers::Signer;
use ethers::types::U256;
use starknet::providers::jsonrpc::JsonRpcTransport as StarknetJsonRpcTransport;
use tokio::time::{interval, MissedTickBehavior};
use tracing::{debug, error, info, warn};

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

                // Update metrics
                self.metrics.record_balance_poll_success(
                    poll_duration,
                    l1_balance_eth,
                );

                if let Some(gp) = gas_price_gwei {
                    self.metrics.update_gas_price(gp);
                }

                // Store historical data
                let snapshot = BalanceSnapshot::new(l1_balance_eth, gas_price_gwei);
                self.balance_history.add_snapshot(snapshot).await;

                match gas_price_gwei {
                    Some(gp) => info!(
                        "Balance poll successful: L1={:.6} ETH, Gas={:.6} Gwei, Duration={:.3}s",
                        l1_balance_eth,
                        gp,
                        poll_duration
                    ),
                    None => info!(
                        "Balance poll successful: L1={:.6} ETH, Gas=FAILED, Duration={:.3}s",
                        l1_balance_eth,
                        poll_duration
                    )
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

    /// Get L1 (Ethereum) balance and current gas price
    async fn get_l1_balance_and_gas(&self) -> eyre::Result<(U256, Option<U256>)> {
        let wallet_address = self.config.wallet().address();

        // Get balance and gas price concurrently
        let provider = self.config.l1_provider();
        let balance_future = provider.get_balance(wallet_address, None);
        let gas_price_future = provider.get_gas_price();

        let (balance_result, gas_price_result) =
            tokio::join!(balance_future, gas_price_future);

        let balance = balance_result.map_err(|e| {
            warn!("Failed to get L1 balance: {}", e);
            eyre::eyre!("L1 balance query failed: {}", e)
        })?;

        let gas_price = match gas_price_result {
            Ok(gp) => {
                // info!("Gas price fetched successfully: {} wei ({:.6} Gwei)", gp, wei_to_gwei(gp));
                Some(gp)
            },
            Err(e) => {
                error!("Failed to get gas price: {}", e);
                None
            }
        };

        debug!("L1 balance: {} wei", balance);

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
    let eth_divisor = U256::from(10).pow(18.into());
    let eth_value = wei.as_u128() as f64 / eth_divisor.as_u128() as f64;
    eth_value
}

/// Convert Wei to Gwei
fn wei_to_gwei(wei: U256) -> f64 {
    let gwei_divisor = U256::from(10).pow(9.into());
    let gwei_value = wei.as_u128() as f64 / gwei_divisor.as_u128() as f64;
    gwei_value
} 