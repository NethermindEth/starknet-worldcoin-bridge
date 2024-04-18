use verifier::math::mod_exp;

#[derive(Copy, Drop)]
struct Input {
    a: u256,
    b: u256,
}

// The tests results are based on the results of the following solidity code, that forks mainnet, 
// calls precompiles and checks the results: https://github.com/ametel01/precompiles-test
// The tests are not exhaustive, but they are enough to check the correctness of the implementation.
#[test]
fn test_mod_exp1() {
    let input = Input {
        a: 88009966869426586326054793412191768538473160230674771117477940242756393061596,
        b: 26859873616407055777888130878028564851092662860690821559568496789771229719829    };
    let expected = 4957037684828371349028486368725664008193737461084841662327841118011875819652;
    let result = mod_exp(input.a, input.b);
    assert!(result == expected, "expected: {}, got: {}", expected, result);
}
#[test]
fn test_mod_exp2() {
    let input = Input {
        a: 93667503498896458261407306500057094676219597639533874203386136785807221185302,
        b: 111428508365352931550624576324203418340994476305059542821500624059522255446943
    };
    let expected = 14955510965618577433222413147363295283252370408258662219190262624397440080484;
    let result = mod_exp(input.a, input.b);
    assert!(result == expected, "expected: {}, got: {}", expected, result);
}

#[test]
fn test_mod_exp3() {
    let input = Input {
        a: 51975646149777427225591377862541090934072341051232032113663076267066374577643,
        b: 35433636764249395195270674567293738806335972712693981327311940281586311300523
    };
    let expected = 18996017004566952035009481843217505117235028394386860659197855190672727117699;
    let result = mod_exp(input.a, input.b);
    assert!(result == expected, "expected: {}, got: {}", expected, result);
}

#[test]
fn test_mod_exp4() {
    let input = Input {
        a: 72111615014240868284401795027124910731563816141063315588908245253917783739138,
        b: 23871971065522574357553439901048733015293143682056318050369423778891598371820
    };
    let expected = 3360566660006660975310328994886964743084178979045029462799534000492932041695;
    let result = mod_exp(input.a, input.b);
    assert!(result == expected, "expected: {}, got: {}", expected, result);
}

#[test]
fn test_mod_exp5() {
    let input = Input {
        a: 83917932059576177844593212159376756472834927365399402259593055521848367587958,
        b: 64190350430070396769712823371732768000054576721173858953801641447924819750451
    };
    let expected = 10964846867464593098788738764887769235104271241272529621706708198270829442320;
    let result = mod_exp(input.a, input.b);
    assert!(result == expected, "expected: {}, got: {}", expected, result);
}


