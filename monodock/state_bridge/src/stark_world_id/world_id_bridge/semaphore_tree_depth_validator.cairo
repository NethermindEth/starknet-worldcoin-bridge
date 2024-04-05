/// SemaphoreTreeDepthValidator 
/// @notice Checks if the provided `treeDepth` is among supported depths.
///
/// @param treeDepth The tree depth to validate.
/// @return supportedDepth Returns `true` if `treeDepth` is between 16 and 32
#[external(v0)]
pub fn validate(tree_depth: u8) -> bool {
    let min_depth: u8 = 16;
    let max_depth: u8 = 32;
    tree_depth >= min_depth && tree_depth <= max_depth
}