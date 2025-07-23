use std::sync::Arc;
use std::time::Duration;

use state_bridge_service::config::cli::Cli;
use state_bridge_service::config::config::Config;
use state_bridge_service::core::state_bridge::ReconnectionConfig;
use state_bridge_service::telemetry::TelemetryConfig;

use clap::Parser;
use eyre::Result;
use state_bridge_service::core::state_bridge::StateBridge;

use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() -> Result<()> {
    // if cfg!(feature = "debug") {
    let env_filter = EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info"));
    fmt()
        .with_env_filter(env_filter)
        .with_target(false)
        .with_level(true)
        .init();
    // }

    let cli = Cli::parse();
    let config = Config::new_from_cli(&cli).await?;

    // Configure telemetry with 30-second polling interval
    let telemetry_config = TelemetryConfig::default()
        .with_poll_interval(Duration::from_secs(30))
        .with_prometheus_address("0.0.0.0:9091".to_string());

    // Configure WebSocket reconnection behavior
    let reconnection_config = ReconnectionConfig {
        max_retries: 0, // Infinite retries for production
        initial_delay: Duration::from_secs(2),
        max_delay: Duration::from_secs(60),
        backoff_multiplier: 1.0,
        connection_timeout: Duration::from_secs(30),
    };

    let state_bridge = StateBridge::from_config(config)?
        .with_telemetry(telemetry_config)
        .await?
        .with_reconnection_config(reconnection_config);

    tracing::info!("Starting State Bridge with telemetry and reconnection enabled");
    tracing::info!("Metrics available at: http://0.0.0.0:9091/metrics");
    tracing::info!("WebSocket reconnection: enabled with backoff (2s)");

    Arc::new(state_bridge).start().await?;

    Ok(())
}
