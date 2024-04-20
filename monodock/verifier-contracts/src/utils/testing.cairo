fn assert_array_result(result: Array<u256>, expected: Array<u256>) {
    let mut i = 0;
    while (i < 12) {
        assert!(
            result.at(i) == expected.at(i), "Expected: {}, got: {}", expected.at(i), result.at(i)
        );
        i += 1;
    }
}
