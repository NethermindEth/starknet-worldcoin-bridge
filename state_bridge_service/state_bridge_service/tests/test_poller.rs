use std::time::Duration;
use tokio::time::Instant;

use state_bridge_service::core::state_bridge::{compute_next_poll_deadline, PollSignal};

#[test]
fn poller_expedite_does_not_delay_deadline() {
    let now = Instant::now();
    let poll_interval = Duration::from_secs(60);
    let reconnect_delay = Duration::from_secs(30);
    let current_deadline = now + Duration::from_secs(10);

    let deadline = compute_next_poll_deadline(
        now,
        current_deadline,
        PollSignal::Expedite,
        poll_interval,
        reconnect_delay,
    );

    assert_eq!(deadline, current_deadline);
}