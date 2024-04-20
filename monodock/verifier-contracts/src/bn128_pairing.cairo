use verifier::bn128_curve::{G1Point, G1PointTrait};
use verifier::utils::math::U256PowerTrait;
use core::integer::{u256_wide_mul, u512_safe_divmod_by_u256, u512};
use verifier::field_elements::{FQ, FQTrait};

const LOG_ATE_LOOP_COUNT: usize = 63;

fn linefunc(p1: G1Point, p2: G1Point, t: G1Point) -> FQ {
    let x1 = p1.x;
    let y1 = p1.y;
    let x2 = p2.x;
    let y2 = p2.y;
    let xt = t.x;
    let yt = t.y;

    if x1 != x2 {
        let m = (y2 - y1) / (x2 - x1);
        return m * (xt - x1) - (yt - y1);
    } else if y1 == y2 {
        let m = FQTrait::from(3) * x1 * x1 / (y1 * y1);
        return m * (xt - x1) - (yt - y1);
    } else {
        return xt - x1;
    }
}


#[cfg(test)]
mod tests {
    use super::linefunc;
    use verifier::bn128_curve::{G1Point, G1PointTrait};

    #[test]
    fn test_linefunc() {
        let p1 = G1PointTrait::from(
            x: 19568893707760843340848992184233194433177372925415116053368211122719346671126,
            y: 11639469568629189918046964192305250472192697612201524135560178632824282818614
        );
        let p2 = G1PointTrait::from(
            x: 5317268879687484957437879782519918549127939892210247573193613900261494313825,
            y: 528174394975085006443543773707702838726735933116136102590448357278717993744
        );
        let t = G1PointTrait::from(
            x: 20258475136311513062630088250818794738180558150268668361907212708339818078766,
            y: 20607871940629074251429330251634508140234793895949264814581235904209210089792
        );
        let res = linefunc(p1, p2, t);
        println!("linefunc result: {:?}", res);
    }
}

