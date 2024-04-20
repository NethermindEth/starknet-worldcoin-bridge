use verifier::bn128_curve::{G1Point, G1PointTrait, G2PointTrait, twist};
use verifier::field_elements::{FQTrait, FQ12Trait};

#[test]
fn test_add_points() {
    let A = G1PointTrait::from(
        14865918005176722116473730206622066845866539143554731094374354951675249722731,
        3197770568483953664363740385883457803041685902965668289308665954510373380344
    );
    let B = G1PointTrait::from(
        6863358721495494421022713667808247652425178970453300712435830652679038918987,
        15025816433373311798308762709072064417001390853103872064614174594927359131281
    );
    let expected = G1PointTrait::from(
        17383244695204108020107085790879405099343391010239272595435842730682893986155,
        14955740362793358104458623534214358840044112411321902980064358605189536665797
    );
    let result = A.add(B);
    assert!(result == expected, "Test: test_add_points, expected {:?}, got {:?}", expected, result);
}

#[test]
fn test_multiply() {
    let A = G1PointTrait::from(
        14865918005176722116473730206622066845866539143554731094374354951675249722731,
        3197770568483953664363740385883457803041685902965668289308665954510373380344
    );
    let n = 10964846867464593098788738764887769235104271241272529621706708198270829442320;
    let expected = G1PointTrait::from(
        3861037894114278668595409444906817726575053864681695378417542742205555505462,
        5745432420201670217197308560270956754202904136371512334037640114883269905931
    );
    let result = A.mul(n);
    assert!(result == expected, "Test: test_multiply, expected {:?}, got {:?}", expected, result);
}

#[test]
fn test_multiply_small_scalar() {
    let A = G1PointTrait::from(
        14865918005176722116473730206622066845866539143554731094374354951675249722731,
        3197770568483953664363740385883457803041685902965668289308665954510373380344
    );
    let n = 2;
    let expected = G1PointTrait::from(
        3490312067382919991484053836234422823589768489538428366852965728895214559981,
        1954488015891974622446033348111698223759289315482775051782896635882131892284
    );
    let result = A.mul(n);
    assert!(result == expected, "Test: test_multiply, expected {:?}, got {:?}", expected, result);
}

#[test]
fn test_point_double() {
    let A = G1PointTrait::from(
        14865918005176722116473730206622066845866539143554731094374354951675249722731,
        3197770568483953664363740385883457803041685902965668289308665954510373380344
    );
    let expected = G1PointTrait::from(
        3490312067382919991484053836234422823589768489538428366852965728895214559981,
        1954488015891974622446033348111698223759289315482775051782896635882131892284
    );
    let result = A.double();
    assert!(
        result == expected, "Test: test_point_double, expected {:?}, got {:?}", expected, result
    );
}

#[test]
fn test_point_is_on_curve() {
    let A = G1PointTrait::from(
        14865918005176722116473730206622066845866539143554731094374354951675249722731,
        3197770568483953664363740385883457803041685902965668289308665954510373380344
    );
    let b = FQTrait::from(3);
    let result = A.is_on_curve(b);
    assert!(result, "Test: test_point_is_on_curve, expected true, got {:?}", result);
}

#[test]
fn test_fq2_twist() {
    let point = G2PointTrait::from(1, 2, 3, 4);
    let expected_coeff_x: Array<u256> = array![
        0,
        0,
        21888242871839275222246405745257275088696311157297823662689037894645226208566,
        0,
        0,
        0,
        0,
        0,
        2,
        0,
        0,
        0
    ];
    let expected_coeff_y: Array<u256> = array![
        0,
        0,
        0,
        21888242871839275222246405745257275088696311157297823662689037894645226208550,
        0,
        0,
        0,
        0,
        0,
        4,
        0,
        0
    ];
    let result = twist(point);
    assert!(
        result.x.coeffs == expected_coeff_x && result.y.coeffs == expected_coeff_y,
        "Test: test_fq2_twist, expected {:?}, got {:?}",
        (expected_coeff_x, expected_coeff_y),
        (result.x.coeffs, result.y.coeffs)
    );
}
