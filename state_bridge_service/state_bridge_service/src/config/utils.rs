use ethers::types::U256;
use starknet::core::types::Felt;

pub fn into_felt(root: U256) -> eyre::Result<Vec<Felt>> {
    let latest_root_0 = root.low_u128().into();
    let latest_root_1 = (root >> 128).as_u128().into();

    Ok(vec![latest_root_0, latest_root_1])
}

pub fn felts_to_u256(values: &[Felt]) -> eyre::Result<U256> {
    if values.len() != 2 {
        eyre::bail!("Expected 2 felts for u256, got {}", values.len());
    }

    let low_bytes = values[0].to_bytes_be();
    let high_bytes = values[1].to_bytes_be();
    let low = U256::from_big_endian(&low_bytes);
    let high = U256::from_big_endian(&high_bytes);

    Ok(low + (high << 128))
}

#[cfg(test)]
mod tests {
    use super::{felts_to_u256, into_felt};
    use ethers::types::U256;

    #[test]
    fn roundtrip_u256_to_felts() {
        let value = U256::from_dec_str(
            "1234567890123456789012345678901234567890",
        )
        .unwrap();
        let felts = into_felt(value).unwrap();
        let restored = felts_to_u256(&felts).unwrap();

        assert_eq!(value, restored);
    }

    #[test]
    fn felts_to_u256_requires_two_values() {
        let err = felts_to_u256(&[]).unwrap_err().to_string();
        assert!(err.contains("Expected 2 felts"));
    }
}
