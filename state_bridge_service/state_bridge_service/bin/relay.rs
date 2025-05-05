use std::sync::Arc;

use state_bridge_service::config::cli::Cli;
use state_bridge_service::config::config::Config;

use clap::Parser;
use eyre::Result;
use state_bridge_service::{
    config::constants::defaults::{BLOCK_CONFIRMATIONS, RELAYING_PERIOD},
    state_bridge::StateBridge,
};

use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() -> Result<()> {
    let env_filter = EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info"));

    fmt()
        .with_env_filter(env_filter)
        .with_target(false)
        .with_level(true)
        .init();

    let cli = Cli::parse();
    let config = Config::new_from_cli(&cli).await?;

    let state_bridge = Arc::new(StateBridge::from_config(
        config,
        RELAYING_PERIOD,
        BLOCK_CONFIRMATIONS,
    )?);
    
    state_bridge.start().await?;
    Ok(())
}
