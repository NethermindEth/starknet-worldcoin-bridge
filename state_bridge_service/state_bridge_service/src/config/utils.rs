use ethers::types::U256;
use starknet::core::types::Felt;

pub fn into_felt(root: U256) -> eyre::Result<Vec<Felt>> {
    let latest_root_0 = root.low_u128().into();
    let latest_root_1 = (root >> 128).as_u128().into();

    Ok(vec![latest_root_0, latest_root_1])
}
