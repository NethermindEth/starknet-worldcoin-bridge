use state_bridge_service::config::cli::{Cli, Fee, Network};
use state_bridge_service::config::config::{Config, L2RootResult};
use state_bridge_service::core::state_bridge::StateBridge;

use dotenv::dotenv;
use std::path::PathBuf;

/// Live test for comparing L1/L2 roots on Sepolia.
/// Requires environment variables:
/// - SEPOLIA_ETHEREUM_WS_PROVIDER
/// - SEPOLIA_STARKNET_HTTP_PROVIDER
#[tokio::test]
#[ignore]
async fn test_live_get_and_compare_roots() -> eyre::Result<()> {
    load_dotenvs();

    let _ = std::env::var("SEPOLIA_ETHEREUM_WS_PROVIDER")?;
    let _ = std::env::var("SEPOLIA_STARKNET_HTTP_PROVIDER")?;

    let cli = Cli {
        network: Network::Sepolia,
        fee: Fee::Estimate,
    };

    let config = Config::new_from_cli(&cli).await?;
    let l2_result = config.get_l2_root_result().await?;
    let bridge = StateBridge::from_config(config)?;
    let roots_match = bridge.compare_roots().await?;

    if matches!(l2_result, L2RootResult::NoRootsSeen) {
        return Ok(());
    }

    assert!(roots_match, "Expected L1/L2 roots to match");
    Ok(())
}

fn load_dotenvs() {
    let _ = dotenv();

    if let Ok(crate_dir) = std::env::var("CARGO_MANIFEST_DIR") {
        let crate_dir = PathBuf::from(crate_dir);
        let repo_root = crate_dir.parent().and_then(|p| p.parent());

        if let Some(repo_root) = repo_root {
            let _ = dotenv::from_filename(repo_root.join(".env"));
        }
    }
}

