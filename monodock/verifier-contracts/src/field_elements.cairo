use core::integer::{u256_checked_add, u256_checked_sub, u256_wide_mul, u512_safe_divmod_by_u256};
use verifier::utils::math::{U256PowerTrait, wide_mul_mod, max, add_mod, sub_mod};
use verifier::utils::vec::{Felt252Vec, VecTrait, create_zero_values_dict, dict_to_u256_array};

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

    fn one() -> FQ {
        FQ { n: 1 }
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
        let n = add_mod(lhs.n, rhs.n);
        FQ { n }
    }
}

impl FQSub of Sub<FQ> {
    fn sub(lhs: FQ, rhs: FQ) -> FQ {
        let n = sub_mod(lhs.n, rhs.n);
        FQ { n }
    }
}

impl FQMul of Mul<FQ> {
    fn mul(lhs: FQ, rhs: FQ) -> FQ {
        let res = wide_mul_mod(lhs.n, rhs.n);
        FQ { n: res }
    }
}

impl FQDiv of Div<FQ> {
    fn div(lhs: FQ, rhs: FQ) -> FQ {
        let n = wide_mul_mod(lhs.n, rhs.n.inverse());
        FQ { n }
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

#[derive(Copy, Default, Debug, Drop)]
struct FQ2 {
    a: FQ,
    b: FQ,
}

#[generate_trait]
impl FQ2Implementation of FQ2Trait {
    fn from(a: u256, b: u256) -> FQ2 {
        FQ2 { a: FQTrait::from(a), b: FQTrait::from(b) }
    }

    fn one() -> FQ2 {
        FQ2 { a: FQTrait::one(), b: FQTrait::zero() }
    }

    fn zero() -> FQ2 {
        FQ2 { a: FQTrait::zero(), b: FQTrait::zero() }
    }

    fn is_zero(self: FQ2) -> bool {
        self.a.is_zero() && self.b.is_zero()
    }
}

impl FQ2Add of Add<FQ2> {
    fn add(lhs: FQ2, rhs: FQ2) -> FQ2 {
        FQ2 { a: lhs.a + rhs.a, b: lhs.b + rhs.b }
    }
}


impl FQ2Mul of Mul<FQ2> {
    fn mul(lhs: FQ2, rhs: FQ2) -> FQ2 {
        let c0 = lhs.a * lhs.b - rhs.a * rhs.b;
        let c1 = lhs.a * rhs.b + lhs.b * rhs.a;
        FQ2 { a: c0, b: c1 }
    }
}

impl FQ2Eq of PartialEq<FQ2> {
    fn eq(lhs: @FQ2, rhs: @FQ2) -> bool {
        lhs.a == rhs.a && lhs.b == rhs.b
    }
    fn ne(lhs: @FQ2, rhs: @FQ2) -> bool {
        !PartialEq::eq(lhs, rhs)
    }
}

#[derive(Clone, Default, Debug, Drop)]
struct FQ12 {
    coeffs: Array<u256>,
}

#[generate_trait]
impl FQ12mplementation of FQ12Trait {
    fn from(coeffs: Array<u256>) -> FQ12 {
        FQ12 { coeffs: coeffs }
    }

    fn one() -> FQ12 {
        FQ12 { coeffs: array![1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
    }

    fn zero() -> FQ12 {
        FQ12 { coeffs: array![0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
    }

    fn pow(self: FQ12, exp: u256) -> FQ12 {
        if exp.is_zero() {
            return FQ12Trait::one();
        } else if exp == 1 {
            return self;
        } else if exp % 2 == 0 {
            return (self.clone() * self.clone()).pow(exp / 2);
        } else {
            return (self.clone() * (self.clone()).pow(exp / 2)) * self.clone();
        }
    }
}

impl FQ12Mul of Mul<FQ12> {
    fn mul(lhs: FQ12, rhs: FQ12) -> FQ12 {
        let (mut low_values, mut high_values) = create_zero_values_dict(24);
        // # Process each coefficient of the first polynomial
        let fq12_coeffs: Array<u256> = array![
            82,
            0,
            0,
            0,
            0,
            0,
            21888242871839275222246405745257275088696311157297823662689037894645226208565,
            0,
            0,
            0,
            0,
            0
        ];
        let mut i: usize = 0;
        while (i < 12) {
            let mut j: usize = 0;
            let lhs_copy = lhs.clone();
            let rhs_copy = rhs.clone();
            while (j < 12) {
                let value = u256 {
                    low: low_values.get(i + j).unwrap(), high: high_values.get(i + j).unwrap()
                };
                let element = add_mod(
                    value, wide_mul_mod(*lhs_copy.coeffs.at(i), *rhs_copy.coeffs.at(j))
                );
                low_values.set(i + j, element.low);
                high_values.set(i + j, element.high);
                j += 1;
            };
            i += 1;
        };
        // # Reduce the result 
        while (low_values.len() > 12) {
            let exp = low_values.len() - 13;
            let top = u256 { low: low_values.pop().unwrap(), high: high_values.pop().unwrap() };
            let mut i: usize = 0;
            let field_coeffs = fq12_coeffs.clone();
            while (i < 12) {
                let element = u256 {
                    low: low_values.get(i + exp).unwrap(), high: high_values.get(i + exp).unwrap()
                };
                let sub_value = wide_mul_mod(top, *field_coeffs.at(i));
                let new_value = (element + P - sub_value) % P;
                low_values.set(i + exp, new_value.low);
                high_values.set(i + exp, new_value.high);
                i += 1;
            };
        };
        let out = dict_to_u256_array(ref low_values, ref high_values);

        FQ12 { coeffs: out }
    }
}

