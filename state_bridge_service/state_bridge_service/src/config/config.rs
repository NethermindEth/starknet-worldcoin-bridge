use crate::config::constants::addresses::*;
use ethers::prelude::*;

pub struct EnvironmentConfig {
    pub http_local: String,
    pub test_private_key: String
}

pub struct AddressBook {
    pub worldid_router: Address,
    pub identity_manager: Address,
}

impl AddressBook {
    pub fn new() -> Self {
        Self {
            worldid_router: SEPOLIA_WORLDID_ROUTER.parse::<H160>().unwrap(),
            identity_manager: SEPOLIA_IDENTITY_MANAGER.parse::<H160>().unwrap(),
        }
    }
}

