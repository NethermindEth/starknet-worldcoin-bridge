use verifier::field_elements::{FQ12, FQ12Trait};

#[test]
fn test_fq12_mul() {
    let p1 = FQ12 { coeffs: array![6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
    let p2 = FQ12 { coeffs: array![4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };

    let p3 = p1 * p2;
    println!("{:?}", p3);
}
