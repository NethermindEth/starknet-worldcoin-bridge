/// Constants
/// Addresses taken from https://docs.world.org/world-id/reference/address-book

pub mod addresses {
    pub const SEPOLIA_WORLDID_ROUTER: &str = "0xb2EaD588f14e69266d1b87936b75325181377076";
    pub const SEPOLIA_IDENTITY_MANAGER: &str = "0x8dD81147685Dc88B6531cCE6b1a71221Be520d62";
    pub const MAINNET_WORLDID_ROUTER: &str = "0x163b09b4fE21177c455D850BD815B6D583732432";
    pub const MAINNET_IDENTITY_MANAGER: &str = "0xf7134CE138832c1456F2a91D64621eE90c2bddEa";

    pub const SEPOLIA_BRIDGE_L1: &str = "0xb6455FCb8e092aB70C7195709AbF3832ff9a6F34";
    pub const SEPOLIA_BRIDGE_L2: &str =
        "0x05d5fbb9d968eb019d9066dd5a92d589fc56f0f45b9301afd3a29b3b79476dd3";
    pub const MAINNET_BRIDGE_L1: &str = "";
    pub const MAINNET_BRIDGE_L2: &str = "";
}

pub mod chain_ids {
    pub const SEPOLIA_CHAIN_ID: u64 = 11155111;
    pub const MAINNET_CHAIN_ID: u64 = 1;
}

pub mod defaults {
    use std::time::Duration;

    pub const RELAYING_PERIOD: Duration = Duration::new(43200, 0); // 12 hours
    pub const BLOCK_CONFIRMATIONS: usize = 0;
    pub const DEFAULT_GAS: u32 = 300000;

    pub const HANDLE_RECEIVE_ROOT_SELECTOR: &str =
        "0x01ec02fa6378eca6ce8f976f7e74ad1a2241692571db908bc34270508d025cf4";
}