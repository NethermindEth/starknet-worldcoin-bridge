/// Constants
/// Addresses taken from https://docs.world.org/world-id/reference/address-book

pub mod addresses {
    pub const SEPOLIA_WORLDID_ROUTER: &str = "0xb2EaD588f14e69266d1b87936b75325181377076";
    pub const SEPOLIA_IDENTITY_MANAGER: &str = "0x8dD81147685Dc88B6531cCE6b1a71221Be520d62";
    pub const MAINNET_WORLDID_ROUTER: &str = "0x163b09b4fE21177c455D850BD815B6D583732432";
    pub const MAINNET_IDENTITY_MANAGER: &str = "0xf7134CE138832c1456F2a91D64621eE90c2bddEa";
}

pub mod chain_ids {
    pub const SEPOLIA_CHAIN_ID: u64 = 11155111;
    pub const MAINNET_CHAIN_ID: u64 = 1;
}

pub mod defaults {
    pub const DEFAULT_GAS: u32 = 1000000;
}
