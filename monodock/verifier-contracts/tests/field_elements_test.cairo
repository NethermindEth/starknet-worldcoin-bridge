use verifier::field_elements::{FQ12, FQ12Trait, FQ2, FQTrait};

#[test]
fn test_fq2_add() {
    let p1 = FQ2{a: FQTrait::from(51975646149777427225591377862541090934072341051232032113663076267066374577643), b: FQTrait::from(3)};
    let p2 = FQ2{a: FQTrait::from(35433636764249395195270674567293738806335972712693981327311940281586311300523), b: FQTrait::from(5)};
    let result = p1 + p2;
    println!("Result: {:?}", result);
}

#[test]
fn test_fq2_mul() {
    let p1 = FQ2{a: FQTrait::from(2), b: FQTrait::from(3)};
    let p2 = FQ2{a: FQTrait::from(4), b: FQTrait::from(5)};
    let result = p1 * p2;
    println!("Result: {:?}", result);
}

#[test]
fn test_fq12_mul() {
    let p1 = FQ12 {
        coeffs: array![
            51975646149777427225591377862541090934072341051232032113663076267066374577643,
            0,
            0,
            0,
            0,
            0,
            0,
            2187487,
            12,
            12,
            12,
            12
        ]
    };
    let p2 = FQ12 {
        coeffs: array![
            35433636764249395195270674567293738806335972712693981327311940281586311300523,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ]
    };
    // let expected = 20769674684598508043618041718740339409206907805908282378460349073110900292610;

    let result = p1 * p2;
    println!("Result: {:?}", result);
    // assert!(
    //     *result.coeffs.at(0) == expected, "Expected: {}, got: {}", expected, *result.coeffs.at(0)
    // );
}
