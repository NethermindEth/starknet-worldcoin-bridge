use starknet::core::types::{BlockId, EventFilter, FieldElement};
use starknet::providers::jsonrpc::HttpTransport;
use starknet::providers::{JsonRpcClient, Provider, Url};
pub struct EventListener {
    pub provider: JsonRpcClient<HttpTransport>,
}

impl EventListener {
    pub fn new(rpc: &str) -> Self {
        Self {
            provider: JsonRpcClient::new(HttpTransport::new(Url::parse(rpc).unwrap())),
        }
    }

    pub async fn get_events(
        &self,
        from_block: Option<BlockId>,
        to_block: Option<BlockId>,
        address: Option<FieldElement>,
        keys: Option<Vec<Vec<FieldElement>>>,
    ) -> eyre::Result<starknet::core::types::EventsPage> {
        let event_filter = EventFilter {
            from_block,
            to_block,
            address,
            keys,
        };

        let events = self.provider.get_events(event_filter, None, 100).await?;

        Ok(events)
    }
}
