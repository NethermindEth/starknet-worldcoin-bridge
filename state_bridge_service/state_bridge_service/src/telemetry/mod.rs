//! Telemetry module for monitoring and metrics collection
//!
//! This module provides comprehensive monitoring capabilities for the State Bridge Service,
//! including balance polling, transaction metrics, and performance monitoring.

pub mod balance_monitor;
pub mod config;
pub mod exporter;
pub mod metrics;

pub use balance_monitor::BalanceMonitor;
pub use config::TelemetryConfig;
pub use exporter::MetricsExporter;
pub use metrics::Metrics;

use eyre::Result;

/// Initialize the telemetry system with default configuration
pub async fn init_telemetry(config: TelemetryConfig) -> Result<(MetricsExporter, Metrics)> {
    let exporter = MetricsExporter::new(config.prometheus_bind_address.clone()).await?;
    let metrics = Metrics::new();

    tracing::info!(
        "Telemetry system initialized on {}",
        config.prometheus_bind_address
    );

    Ok((exporter, metrics))
}
