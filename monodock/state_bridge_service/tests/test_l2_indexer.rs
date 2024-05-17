use starknet::core::types::BlockId;
use starknet::providers::Provider;

use state_bridge_service::l2_listener::EventListener;

// Grabs events from L2
// This can be expanded upon to pipe addresses to a database
#[tokio::test]
async fn test_l2_indexer() -> eyre::Result<()> {
    let client = EventListener::new("http://0.0.0.0:5050");
    let block_number_to = client.provider.block_number().await?;
    let block_number_from: u64 = 0;

    let events = client
        .get_events(
            Some(BlockId::Number(block_number_from)),
            Some(BlockId::Number(block_number_to)),
            None,
            None,
        )
        .await?;

    Ok(())
}
