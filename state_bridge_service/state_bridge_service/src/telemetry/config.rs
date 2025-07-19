use serde::{Deserialize, Serialize};
use std::time::Duration;

/// Configuration for the telemetry system
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TelemetryConfig {
    /// Address to bind Prometheus metrics server to
    pub prometheus_bind_address: String,
    
    /// How frequently to poll for balance updates
    pub balance_poll_interval: Duration,
    
    /// Enable detailed transaction metrics
    pub enable_transaction_metrics: bool,
    
    /// Enable gas usage tracking
    pub enable_gas_metrics: bool,
    
    /// Maximum number of balance history entries to keep
    pub max_balance_history: usize,
}

impl Default for TelemetryConfig {
    fn default() -> Self {
        Self {
            prometheus_bind_address: "0.0.0.0:9091".to_string(),
            balance_poll_interval: Duration::from_secs(30), // Poll every 30 seconds
            enable_transaction_metrics: true,
            enable_gas_metrics: true,
            max_balance_history: 1000,
        }
    }
}

impl TelemetryConfig {
    /// Create a new telemetry config with custom poll interval
    pub fn with_poll_interval(mut self, interval: Duration) -> Self {
        self.balance_poll_interval = interval;
        self
    }
    
    /// Create a new telemetry config with custom prometheus address
    pub fn with_prometheus_address(mut self, address: String) -> Self {
        self.prometheus_bind_address = address;
        self
    }
} 