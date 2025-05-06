use std::time::Duration;

use crate::config::constants::defaults::{BLOCK_CONFIRMATIONS, RELAYING_PERIOD};

#[derive(Clone, Debug)]
pub struct BridgeConfig {
    /// Time delay between `propagateRoot()` transactions
    pub relaying_period: Duration,
    /// The number of block confirmations before a `propagateRoot()` transaction is considered finalized
    pub block_confirmations: usize,
}

impl Default for BridgeConfig {
    fn default() -> Self {
        Self {
            relaying_period: RELAYING_PERIOD,
            block_confirmations: BLOCK_CONFIRMATIONS,
        }
    }
}
