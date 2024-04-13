use verifier::ec_math::{ec_add, Point};

// The tests results are based on the results of the following solidity code, that forks mainnet, 
// calls precompiles and checks the results: https://github.com/ametel01/precompiles-test
// The ec points are sourced from here: https://github.com/worldcoin/world-id-state-bridge/blob/main/src/test/SemaphoreVerifier16.sol
// The tests are not exhaustive, but they are enough to check the correctness of the implementation.
#[test]
fn test_ec_add1() {
    let a = Point {
        x: 19568893707760843340848992184233194433177372925415116053368211122719346671126,
        y: 11639469568629189918046964192305250472192697612201524135560178632824282818614
    };
    let b = Point {
        x: 5317268879687484957437879782519918549127939892210247573193613900261494313825,
        y: 528174394975085006443543773707702838726735933116136102590448357278717993744
    };
    let expected = Point {
        x: 20258475136311513062630088250818794738180558150268668361907212708339818078766,
        y: 20607871940629074251429330251634508140234793895949264814581235904209210089792
    };
    let result = ec_add(a, b);
    assert!(
        result.x == expected.x && result.y == expected.y,
        "expected: {:?}, got: {:?}",
        expected,
        result
    );
}

#[test]
fn test_ec_add2() {
    let a = Point {
        x: 14865918005176722116473730206622066845866539143554731094374354951675249722731,
        y: 3197770568483953664363740385883457803041685902965668289308665954510373380344
    };
    let b = Point {
        x: 6863358721495494421022713667808247652425178970453300712435830652679038918987,
        y: 15025816433373311798308762709072064417001390853103872064614174594927359131281
    };
    let expected = Point {
        x: 17383244695204108020107085790879405099343391010239272595435842730682893986155,
        y: 14955740362793358104458623534214358840044112411321902980064358605189536665797
    };
    let result = ec_add(a, b);
    assert!(
        result.x == expected.x && result.y == expected.y,
        "expected: {:?}, got: {:?}",
        expected,
        result
    );
}
