use starknet::providers::jsonrpc::{HttpTransport, JsonRpcTransport};
use starknet::providers::{JsonRpcClient, Provider, Url};

pub struct EventListener<T> {
    provider: JsonRpcClient<T>,
}

impl<T: 'static + JsonRpcTransport + Sync + Send> EventListener<T> {
    fn new(url: &str) -> Self {
        let url = Url::parse(url).unwrap();
        let json_rpc_transport = HttpTransport::new(url);
        Self { json_rpc_transport }
    }

    fn get_events(&self) {
        //JsonRpcClient
    }
}
