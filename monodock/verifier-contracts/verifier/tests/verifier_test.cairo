use snforge_std::{declare, ContractClassTrait};
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq, fq2, fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
use verifier::{Proof, Input};
use verifier::constants::vk;
use verifier::semaphore::{Verifier, IVerifierDispatcher, IVerifierDispatcherTrait};


fn proof() -> (Proof, Input) {
    let a_x = 12214106092490461744224237722729645351215031798064303243709025430550348378829;
    let a_y = 21027909390216654990127744437773937225109739023736651373154237798119299568212;

    let b1_x = 269720002102256740992639069395876333753617844286711085747511399990849314042;
    let b0_x = 10909524402927789121683327447993582801213694924004249146145464851610397847539;
    let b1_y = 8385025288852389347030999220763801738560279965758351494773898439925187849200;
    let b0_y = 10598183529388435714167151196880541936910131510610645221683168963020600699163;

    let c_x = 19196574429813560394939050359656501242700200001516170674712014858999213697832;
    let c_y = 9119788027758022424697695015658068118765307064558369750021625349720105431548;

    let root = 9909282791234442577148781041178775447957389612636950228211340754569685751476;
    let signal = 332910598242053211795222349365649310569639162668825895570972839236209676575;
    let nullifier = 1796892255657002109914607393057088853633871711848701703534586517840122057144;
    let ext_nullifier = 447413433400125861047685511869182644117539243278160224138376569474905112439;

    (
        Proof { a_x, a_y, b1_x, b0_x, b1_y, b0_y, c_x, c_y },
        Input { root, signal, nullifier, ext_nullifier }
    )
}

#[test]
fn test_verify_integration_success() {
    let verifier = deploy();

    let (proof, input) = proof();

    let result = verifier.verify_proof(proof, input);
    assert(result, 'verification failed');
}

#[test]
#[should_panic()]
fn test_verify_integration_fails() {
    let verifier = deploy();

    let (mut proof, input) = proof();
    proof.a_x = 0;

    verifier.verify_proof(proof, input);
}


#[test]
fn test_alphabeta_precompute() {
    let (alpha, beta_neg, _, _, alphabeta_miller, _, _, _, _, _) = vk();
    let ate_miller_loop = ate_miller_loop(alpha, beta_neg);
    assert(alphabeta_miller == ate_miller_loop, 'incorrect miller precompute');
}

#[test]
fn test_points_on_curve() {
    let (alpha, beta, gamma, delta, _, ic0, ic1, ic2, ic3, ic4) = vk();

    assert!(is_on_curve_g1(alpha), "alpha is not on curve");
    assert!(is_on_curve_g2(beta), "beta is not on curve");
    assert!(is_on_curve_g2(gamma), "gamma is not on curve");
    assert!(is_on_curve_g2(delta), "delta is not on curve");
    assert!(is_on_curve_g1(ic0), "ic0 is not on curve");
    assert!(is_on_curve_g1(ic1), "ic1 is not on curve");
    assert!(is_on_curve_g1(ic2), "ic2 is not on curve");
    assert!(is_on_curve_g1(ic3), "ic3 is not on curve");
    assert!(is_on_curve_g1(ic4), "ic4 is not on curve");
}

fn deploy() -> IVerifierDispatcher {
    let contract = declare("Verifier").unwrap();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    IVerifierDispatcher { contract_address }
}


fn is_on_curve_g1(pt: AffineG1) -> bool {
    return (pt.y * pt.y) - (pt.x * pt.x * pt.x) == fq(3);
}

fn is_on_curve_g2(pt: AffineG2) -> bool {
    return (pt.y * pt.y) - (pt.x * pt.x * pt.x) == fq2(3, 0) / fq2(9, 1);
}
