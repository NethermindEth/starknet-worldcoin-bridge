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

    // ❷ Build a subscriber that prints to stdout with nice colors
    fmt()
        .with_env_filter(env_filter)
        .with_target(false) // hide `my_crate::module` by default
        .with_level(true) // show log level in brackets
        .init(); // <- GLOBAL; call exactly once

    let cli = Cli::parse();
    let config = Config::new_from_cli(&cli).await?;

    let state_bridge =
        StateBridge::from_config(config.clone(), RELAYING_PERIOD, BLOCK_CONFIRMATIONS)?; //todo: fix clone
    state_bridge.watch_and_execute(config).await?;

    Ok(())
}
