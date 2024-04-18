use core::integer::{u256_wide_mul, u512_safe_divmod_by_u256};
use verifier::field_elements::P;

/// Performs modular exponentiation on `base` raised to `exp`, mod `P`.
///
/// The function efficiently calculates `(base^exp) % P` using reduction techniques based on Fermat's Little Theorem,
/// which states that if `P` is prime, then `(a^(P-1)) % P = 1` for any integer `a`. By reducing `exp` modulo `P-1`,
/// the function optimizes the exponentiation for large exponents.
///
/// # Parameters
/// - `base`: The base of the exponentiation, a `u256` integer.
/// - `exp`: The exponent, a `u256` integer.
fn mod_exp(base: u256, exp: u256) -> u256 {
    // Since mod is prime, we can use Fermat's Little Theorem to reduce the exponent modulo (mod-1)
    let mut exp = exp % (P - 1); // Reduce the exponent
    let mut base = base % P; // Reduce the base modulo mod initially

    power(base, exp)
}

#[generate_trait]
impl U256PowerImpl of U256PowerTrait {
    fn pow(self: u256, exp: u256) -> u256 {
        power(self, exp)
    }

    fn inverse(self: u256) -> u256 {
        mod_inv(self)
    }
}


/// Computes the modular multiplicative inverse of `a` under the modulus `P`.
///
/// # Parameters
/// - `a`: The number to find the modular inverse of, of type `u256`.
///
/// # Returns
/// - `u256`: The modular inverse of `a` if `a` and `P` are coprime.
fn mod_inv(a: u256) -> u256 {
    a.pow(P - 2)
}


/// Calculates `base` raised to the power of `exp` using modular exponentiation under a predefined modulus `P`.
/// This function employs the square-and-multiply algorithm optimized for performance in finite fields.
///
/// # Parameters
/// - `base`: The base of the exponentiation of type `u256`.
/// - `exp`: The exponent of the exponentiation of type `u256`.
///
/// # Returns
/// - `u256`: The result of `base^exp % P`.
fn power(mut base: u256, mut exp: u256) -> u256 {
    let mut result: u256 = 1;
    while(!exp.is_zero())
    {
        if !(exp % 2)
            .is_zero() { // If the least significant bit is 1, multiply the base with the result
            let (_, r, _, _, _, _, _) = u512_safe_divmod_by_u256(
                u256_wide_mul(result, base), P.try_into().unwrap()
            );
            result = r;
        }
        let (_, b, _, _, _, _, _) = u512_safe_divmod_by_u256(
            u256_wide_mul(base, base), P.try_into().unwrap()
        ); // Square the base
        base = b;
        exp /= 2; // Right shift the exponent
    };
    result
}

