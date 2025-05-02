use clap::{Parser, ValueEnum};
use dotenv::dotenv;
use ethers::prelude::*;
use eyre::Result;
use state_bridge_service::state_bridge::StateBridge;
use std::{sync::Arc, time::Duration};

use state_bridge_service::config::cli::Cli;
use state_bridge_service::config::config::Config;
use std::str::FromStr;
use ethers::types::U256;
use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() -> Result<()> {
    let env_filter =
        EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info"));

    // ❷ Build a subscriber that prints to stdout with nice colors
    fmt()
        .with_env_filter(env_filter)
        .with_target(false)   // hide `my_crate::module` by default
        .with_level(true)     // show log level in brackets
        .init();              // <- GLOBAL; call exactly once

    let cli = Cli::parse();
    let config = Config::new_from_cli(&cli).await?;
    let l1_provider = config.l1_provider.clone(); 
    let fee = config.get_fee().await?;

    let event_name = "TreeChanged(uint256,uint8,uint256)";

    // Option Setup
    let relaying_period = Duration::new(43200, 0);
    let block_confirmations = 0;
    const DEFAULT_GAS: u32 = 300000;

    // Filter Events
    let filter = Filter::new().address(config.world_address_book.worldid_router).event(event_name);

    // New State Bridge Service
    let state_bridge = StateBridge::from_config(config, relaying_period, block_confirmations)?; 

    // Event based root propogation
    let mut stream = l1_provider.watch(&filter).await?.stream();

    
    while let log = stream.next().await {
        match log {
            Some(log) => {
                let res = state_bridge.propagate_root(fee.to_bytes_be().into())
                .await;

                match res {
                    Ok(()) => println!("ok"),
                    Err(e) => println!("error: {:?}", e),
                }

                println!("Event detected: {:?}", log);
            }
            None => {
                eprintln!("Error listening to events");
            }
        }
    }

    // Single call rootPropogate()
    // let res = StateBridge::propagate_root(
    //     l1_state_bridge,
    //     &test_wallet,
    //     block_confirmations,
    //     provider.clone(),
    //     DEFAULT_GAS,
    // )
    // .await;

    // match res {
    //     Ok(()) => println!("ok"),
    //     Err(e) => println!("error: {:?}", e),
    // }

    // Interval Based Root Propagation
    // let join_handle = state_bridge.spawn(DEFAULT_GAS);

    // match join_handle.await {
    //     Ok(Ok(result)) => println!("Task result: {:?}", result),
    //     Ok(Err(e)) => eprintln!("Task error: {}", e),
    //     Err(e) => eprintln!("Join error: {:?}", e),
    // }

    Ok(())
}
