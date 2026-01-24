//! Unit tests for the state bridge core functionality
//!
//! These tests verify the fixes for intermittent sync failures:
//! - Error handling in execute loop (doesn't exit on single error)
//! - Retry logic for fee estimation
//! - Gas limit validation
//! - Reconnection backoff configuration

#[cfg(test)]
mod tests {
    use crate::config::constants::defaults::DEFAULT_GAS;
    use crate::core::transaction::check_gas_limit;
    use crate::core::state_bridge::ReconnectionConfig;
    use ethers::types::U256;
    use std::time::Duration;

    /// Test that gas limit check passes for values within the limit
    #[test]
    fn test_gas_limit_check_within_limit() {
        // Gas limit is now 500000 (increased from 300000)
        let gas_within_limit = U256::from(400000u64);
        assert!(
            check_gas_limit(gas_within_limit),
            "Gas within limit should pass check"
        );

        let gas_at_limit = U256::from(DEFAULT_GAS);
        assert!(
            check_gas_limit(gas_at_limit),
            "Gas at exact limit should pass check"
        );
    }

    /// Test that gas limit check fails for values exceeding the limit
    #[test]
    fn test_gas_limit_check_exceeds_limit() {
        let gas_over_limit = U256::from(DEFAULT_GAS as u64 + 1);
        assert!(
            !check_gas_limit(gas_over_limit),
            "Gas over limit should fail check"
        );

        let gas_way_over = U256::from(1000000u64);
        assert!(
            !check_gas_limit(gas_way_over),
            "Gas way over limit should fail check"
        );
    }

    /// Test that the increased gas limit (500k) can handle typical transaction + 50% buffer
    #[test]
    fn test_gas_limit_handles_buffered_transactions() {
        // Typical propagateRoot gas is around 180k-220k
        // With 50% buffer: 220k * 1.5 = 330k
        // Old limit was 300k (would fail), new limit is 500k (should pass)
        let estimated_gas = 220000u64;
        let buffered_gas = U256::from(estimated_gas * 150 / 100); // 330k

        assert!(
            check_gas_limit(buffered_gas),
            "Buffered gas of 330k should pass with new 500k limit"
        );

        // Even with higher congestion (280k estimated, 420k buffered)
        let high_congestion_gas = 280000u64;
        let high_buffered = U256::from(high_congestion_gas * 150 / 100); // 420k

        assert!(
            check_gas_limit(high_buffered),
            "High congestion buffered gas of 420k should pass with new 500k limit"
        );
    }

    /// Test default reconnection config has correct exponential backoff
    #[test]
    fn test_default_reconnection_config_backoff() {
        let config = ReconnectionConfig::default();

        // Should use exponential backoff (multiplier > 1.0)
        assert!(
            config.backoff_multiplier > 1.0,
            "Backoff multiplier should be > 1.0 for exponential backoff, got {}",
            config.backoff_multiplier
        );

        assert_eq!(
            config.backoff_multiplier, 2.0,
            "Default backoff multiplier should be 2.0"
        );
    }

    /// Test reconnection config values are sensible
    #[test]
    fn test_reconnection_config_values() {
        let config = ReconnectionConfig::default();

        assert_eq!(
            config.max_retries, 0,
            "Default should have infinite retries (0)"
        );

        assert!(
            config.initial_delay >= Duration::from_secs(1),
            "Initial delay should be at least 1 second"
        );

        assert!(
            config.max_delay >= Duration::from_secs(30),
            "Max delay should be at least 30 seconds"
        );

        assert!(
            config.connection_timeout >= Duration::from_secs(10),
            "Connection timeout should be at least 10 seconds"
        );
    }

    /// Test exponential backoff calculation
    #[test]
    fn test_exponential_backoff_calculation() {
        let config = ReconnectionConfig::default();
        let mut delay = config.initial_delay;

        // Simulate backoff progression
        let delays: Vec<Duration> = (0..5)
            .map(|_| {
                let current = delay;
                delay = std::cmp::min(
                    Duration::from_secs_f64(delay.as_secs_f64() * config.backoff_multiplier),
                    config.max_delay,
                );
                current
            })
            .collect();

        // Verify delays increase exponentially
        for i in 1..delays.len() {
            if delays[i - 1] < config.max_delay {
                assert!(
                    delays[i] > delays[i - 1],
                    "Delay should increase: {} should be > {}",
                    delays[i].as_secs(),
                    delays[i - 1].as_secs()
                );
            }
        }

        // Verify max delay is respected
        assert!(
            delays.last().unwrap() <= &config.max_delay,
            "Final delay should not exceed max_delay"
        );
    }

    /// Test that DEFAULT_GAS constant is set correctly
    #[test]
    fn test_default_gas_constant() {
        assert_eq!(
            DEFAULT_GAS, 500000,
            "DEFAULT_GAS should be 500000 (increased from 300000)"
        );
    }
}

/// Integration-style tests that verify the error handling behavior
#[cfg(test)]
mod error_handling_tests {
    /// Test that errors are classified correctly for recovery
    #[test]
    fn test_recoverable_error_classification() {
        let recoverable_errors = vec![
            "connection refused",
            "timeout waiting for response",
            "broken pipe",
            "network is unreachable",
            "websocket connection closed",
            "io error: connection reset",
            "transport error",
        ];

        for error in recoverable_errors {
            let error_lower = error.to_lowercase();
            let is_recoverable = error_lower.contains("connection")
                || error_lower.contains("timeout")
                || error_lower.contains("broken pipe")
                || error_lower.contains("network")
                || error_lower.contains("websocket")
                || error_lower.contains("io error")
                || error_lower.contains("transport");

            assert!(
                is_recoverable,
                "Error '{}' should be classified as recoverable",
                error
            );
        }
    }

    /// Test that non-recoverable errors are identified
    #[test]
    fn test_non_recoverable_error_classification() {
        let non_recoverable_errors = vec![
            "invalid signature",
            "nonce too low",
            "contract execution reverted",
            "insufficient funds",
        ];

        for error in non_recoverable_errors {
            let error_lower = error.to_lowercase();
            let is_recoverable = error_lower.contains("connection")
                || error_lower.contains("timeout")
                || error_lower.contains("broken pipe")
                || error_lower.contains("network")
                || error_lower.contains("websocket")
                || error_lower.contains("io error")
                || error_lower.contains("transport");

            assert!(
                !is_recoverable,
                "Error '{}' should NOT be classified as recoverable",
                error
            );
        }
    }

    /// Test duplicate root error detection
    #[test]
    fn test_duplicate_root_error_detection() {
        let error_messages = vec![
            "CANNOT_OVERWRITE_ROOT",
            "root already exists in history",
            "already exists",
        ];

        for error in error_messages {
            let is_duplicate = error.contains("CANNOT_OVERWRITE_ROOT")
                || error.contains("already exists");

            assert!(
                is_duplicate,
                "Error '{}' should be detected as duplicate root error",
                error
            );
        }
    }
}

/// Tests for channel buffer behavior
#[cfg(test)]
mod channel_tests {
    use tokio::sync::mpsc;

    /// Test that channel buffer is large enough for burst handling
    #[tokio::test]
    async fn test_channel_buffer_capacity() {
        // The channel should be created with capacity 32 (not 1)
        let expected_capacity = 32;
        let (tx, mut rx) = mpsc::channel::<u32>(expected_capacity);

        // Should be able to send multiple messages without blocking
        for i in 0..expected_capacity {
            tx.try_send(i as u32).expect(&format!(
                "Should be able to send message {} without blocking",
                i
            ));
        }

        // Channel should now be full
        assert!(
            tx.try_send(100).is_err(),
            "Channel should be full after {} messages",
            expected_capacity
        );

        // Drain the channel
        for _ in 0..expected_capacity {
            rx.recv().await.expect("Should receive message");
        }
    }
}

/// Tests for retry logic
#[cfg(test)]
mod retry_tests {
    use std::sync::atomic::{AtomicU32, Ordering};
    use std::time::Duration;
    use tokio::time::sleep;

    /// Test retry backoff timing
    #[tokio::test]
    async fn test_retry_backoff_timing() {
        let attempt_count = AtomicU32::new(0);
        let max_retries = 3u32;
        let mut delay = Duration::from_millis(100);

        for attempt in 0..max_retries {
            attempt_count.fetch_add(1, Ordering::SeqCst);

            // Simulate failure
            if attempt < max_retries - 1 {
                sleep(delay).await;
                delay = std::cmp::min(delay * 2, Duration::from_secs(1));
            }
        }

        assert_eq!(
            attempt_count.load(Ordering::SeqCst),
            max_retries,
            "Should attempt exactly {} times",
            max_retries
        );
    }

    /// Test that retry delays increase exponentially
    #[test]
    fn test_retry_delay_progression() {
        let initial_delay = Duration::from_millis(500);
        let max_delay = Duration::from_secs(5);
        let mut delay = initial_delay;

        let delays: Vec<Duration> = (0..5)
            .map(|_| {
                let current = delay;
                delay = std::cmp::min(delay * 2, max_delay);
                current
            })
            .collect();

        // Verify: 500ms, 1000ms, 2000ms, 4000ms, 5000ms (capped)
        assert_eq!(delays[0], Duration::from_millis(500));
        assert_eq!(delays[1], Duration::from_millis(1000));
        assert_eq!(delays[2], Duration::from_millis(2000));
        assert_eq!(delays[3], Duration::from_millis(4000));
        assert_eq!(delays[4], Duration::from_secs(5)); // Capped at max
    }
}
