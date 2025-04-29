use dotenv::dotenv;
use ethers::prelude::*;
use eyre::Result;
use std::{sync::Arc, time::Duration};

use state_bridge_service::state_bridge::StateBridge;
use state_bridge_service::config::config::{AddressBook, EnvironmentConfig};

#[tokio::main]
async fn main() -> Result<()> {
    // Environment Variables
    dotenv().ok();
    let http_local = std::env::var("HTTP_TESTNET")?;
    let test_private_key = std::env::var("TEST_PRIVATE_KEY")?;

    let event_name = "TreeChanged(uint256,uint8,uint256)";

    // Interfacing Setup
    let test_wallet: LocalWallet = test_private_key
        .parse::<LocalWallet>()?
        .with_chain_id(11155111 as u64);
    let provider: Arc<Provider<Http>> = Arc::new(Provider::<Http>::connect(&http_local).await);

    // Option Setup
    let worldid_contract = "0xb2EaD588f14e69266d1b87936b75325181377076 ".parse::<H160>()?;
    let l1_state_bridge = "0x8dD81147685Dc88B6531cCE6b1a71221Be520d62".parse::<H160>()?;
    let relaying_period = Duration::new(60, 0);
    let block_confirmations = 0;
    const DEFAULT_GAS: u32 = 1000000;

    // Filter Events
    let filter = Filter::new().address(worldid_contract).event(event_name);

    // New State Bridge Service
    let state_bridge = StateBridge::new(
        l1_state_bridge,
        test_wallet.clone(),
        provider.clone(),
        relaying_period,
        block_confirmations,
    )?;

    // Event based root propogation
    let mut stream = provider.watch(&filter).await?.stream();

    while let log = stream.next().await {
        match log {
            Some(log) => {
                let res = StateBridge::propagate_root(
                    l1_state_bridge,
                    &test_wallet,
                    block_confirmations,
                    provider.clone(),
                    DEFAULT_GAS,
                )
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
