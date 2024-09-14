/// SemaphoreTreeDepthValidator 
/// 
/// Checks if the provided `treeDepth` is among supported depths.
///
/// # Arguments
/// 
/// * 'treeDepth' - The tree depth to validate.
/// 
/// # Returns
/// 
/// Returns `true` if `treeDepth` is between 16 and 32
#[external(v0)]
pub fn validate(tree_depth: u8) -> bool {
    let min_depth: u8 = 16;
    let max_depth: u8 = 32;
    tree_depth >= min_depth && tree_depth <= max_depth
}

#[cfg(test)]
mod tests {
    use super::validate;
    #[test]
    fn test_valid_depth() {
        // valid depths
        let min_depth: u8 = 16;
        assert!(validate(min_depth));

        let max_depth: u8 = 32;
        assert!(validate(max_depth));

        let acceptable_depth: u8 = 20;
        assert!(validate(acceptable_depth));

        // invalid depths
        let invalid_min_depth = 15;
        assert!(!validate(invalid_min_depth));
        
        let invalid_max_depth = 33; 
        assert!(!validate(invalid_max_depth));
    }
}