use std::{sync::Arc, time::Duration};

use ethers::prelude::*;

use state_bridge_service::state_bridge::StateBridge;

// Test to setup async service that calls the rootPropogate function every relaying period
#[tokio::test]
async fn test_relay() -> eyre::Result<()> {
    // Environment Variables
    let http_local = std::env::var("HTTP_ANVIL_LOCAL")?;
    let test_private_key = std::env::var("TEST_PRIVATE_KEY")?;

    // Interfacing Setup
    let test_wallet: LocalWallet = test_private_key
        .parse::<LocalWallet>()?
        .with_chain_id(31337 as u64);
    let provider: Arc<Provider<Http>> = Arc::new(Provider::<Http>::connect(&http_local).await);

    // Option Setup
    let l1_state_bridge = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0".parse::<H160>()?;
    let relaying_period = Duration::new(5, 0);
    let block_confirmations = 0;
    const DEFAULT_GAS: u32 = 1000000;

    // New State Bridge Service
    let state_bridge = StateBridge::new(
        l1_state_bridge,
        test_wallet.clone(),
        provider.clone(),
        relaying_period,
        block_confirmations,
    )?;

    // Single call rootPropogate()
    // let res = StateBridge::propagate_root(
    //     l1_state_bridge,
    //     &test_wallet,
    //     block_confirmations,
    //     provider.clone(),
    //     1000000,
    // )
    // .await;

    // match res {
    //     Ok(()) => println!("ok"),
    //     Err(e) => println!("error: {:?}", e),
    // }

    let join_handle = state_bridge.spawn(DEFAULT_GAS);

    match join_handle.await {
        Ok(Ok(result)) => println!("Task result: {:?}", result),
        Ok(Err(e)) => eprintln!("Task error: {}", e),
        Err(e) => eprintln!("Join error: {:?}", e),
    }

    Ok(())
}
