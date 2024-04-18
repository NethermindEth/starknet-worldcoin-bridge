use core::array::ArrayTrait;
use core::integer::{u256_checked_add, u256_checked_sub, u256_wide_mul, u512_safe_divmod_by_u256};
use verifier::math::{U256PowerTrait, wide_mul_mod, max};

const P: u256 = 21888242871839275222246405745257275088696311157297823662689037894645226208583;


#[derive(Copy, Default, Drop, Debug)]
struct FQ {
    n: u256,
}

#[generate_trait]
impl FQImplementation of FQTrait {
    fn from(n: u256) -> FQ {
        FQ { n: n % P }
    }

    fn pow(self: FQ, exp: u256) -> FQ {
        FQ { n: self.n.pow(exp) }
    }

    fn zero() -> FQ {
        FQ { n: 0 }
    }

    fn is_zero(self: FQ) -> bool {
        self.n == 0
    }

    fn prime() -> FQ {
        FQ { n: P }
    }
}

impl FQAdd of Add<FQ> {
    fn add(lhs: FQ, rhs: FQ) -> FQ {
        let n = u256_checked_add(lhs.n, rhs.n).expect('u256_add Overflow') % P;
        FQ { n: n }
    }
}

impl FQSub of Sub<FQ> {
    fn sub(lhs: FQ, rhs: FQ) -> FQ {
        let n = u256_checked_sub(lhs.n + P, rhs.n).expect('u256_sub Overflow') % P;
        FQ { n: n }
    }
}

impl FQMul of Mul<FQ> {
    fn mul(lhs: FQ, rhs: FQ) -> FQ {
        let (_, res, _, _, _, _, _) = u512_safe_divmod_by_u256(
            u256_wide_mul(lhs.n, rhs.n), P.try_into().unwrap()
        );
        FQ { n: res }
    }
}

impl FQDiv of Div<FQ> {
    fn div(lhs: FQ, rhs: FQ) -> FQ {
        let (_, res, _, _, _, _, _) = u512_safe_divmod_by_u256(
            u256_wide_mul(lhs.n, rhs.n.inverse()), P.try_into().unwrap()
        );
        FQ { n: res }
    }
}

impl FQEq of PartialEq<FQ> {
    fn eq(lhs: @FQ, rhs: @FQ) -> bool {
        lhs.n == rhs.n
    }
    fn ne(lhs: @FQ, rhs: @FQ) -> bool {
        lhs.n != rhs.n
    }
}

#[derive(Clone, Default, Debug, Drop)]
struct FQ12 {
    coeffs: Array<u256>,
}

#[generate_trait]
impl FQ12mplementation of FQ12Trait {
    fn one() -> FQ12 {
        FQ12 { coeffs: array![1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
    }

    fn zero() -> FQ12 {
        FQ12 { coeffs: array![0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
    }
}

impl FQ12Mul of Mul<FQ12> {
    fn mul(lhs: FQ12, rhs: FQ12) -> FQ12 {
        let mut result: Array<u256> = array![];
        // # Process each coefficient of the first polynomial
        let mut i: usize = 0;
        while (i < 12) {
            let mut new_row: Array<u256> = array![];

            let mut i_i = i;
            while i_i > 0 {
                new_row.append(0);
                i_i -= 1;
            };
            let mut j: usize = 0;
            let lhs_copy = lhs.clone();
            let rhs_copy = rhs.clone();
            while (j < 12) {
                // TODO: Optimize this for gas using pop_front() instead of at.
                new_row.append(wide_mul_mod(*lhs_copy.coeffs.at(i), *rhs_copy.coeffs.at(j)));
                j += 1;
            };

            if result.len().is_zero() {
                result = new_row;
            } else {
                let mut combined: Array<u256> = array![];
                let mut max_length = max(result.len(), new_row.len());
                let mut k: usize = 0;
                loop {
                    if max_length == 0 {
                        break;
                    }
                    // TODO: Optimize this for gas using pop_front() instead of at.
                    if k < result.len() && k < new_row.len() {
                        combined.append(*result.at(k) + *new_row.at(k));
                    } else if k < result.len() {
                        combined.append(*result.at(k));
                    } else {
                        combined.append(*new_row.at(k));
                    }
                    k += 1;
                    max_length -= 1;
                };
                result = combined;
            };
            i += 1;
        };
        FQ12 { coeffs: result }
    }
}

