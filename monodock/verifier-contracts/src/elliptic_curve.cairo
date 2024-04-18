use core::integer::{u256_wide_mul, u512_safe_divmod_by_u256, u512};
use verifier::math::U256PowerTrait;
use verifier::field_elements::{FQ, FQ12, FQTrait, FQ12Trait};

const P: u256 = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
const N: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

#[derive(Copy, Debug, Default, Drop)]
struct G1Point {
    x: FQ,
    y: FQ,
}

#[generate_trait]
impl G1PointImpl of G1PointTrait {
    fn from(x: u256, y: u256) -> G1Point {
        G1Point { x: FQTrait::from(x), y: FQTrait::from(y) }
    }

    fn add(self: G1Point, other: G1Point) -> G1Point {
        if self.x == other.x && self.y != other.y {
            return Default::default(); // Point at infinity
        }
        if self == other {
            return self.double();
        }
        add_points(self, other)
    }

    fn double(self: G1Point) -> G1Point {
        if self.y.is_zero() || self.x.is_zero() {
            return Default::default(); // Point at infinity
        }
        return point_double(self);
    }

    fn mul(self: G1Point, scalar: u256) -> G1Point {
        multiply(self, scalar)
    }

    fn is_on_curve(self: G1Point, b: u256) -> bool {
        if self.is_zero() {
            return true;
        }
        let x = self.x;
        let y = self.y;
        y.pow(2) - x.pow(3) == FQTrait::from(b)
    }

    fn is_zero(self: G1Point) -> bool {
        self.x.is_zero() && self.y.is_zero()
    }
}

/// Adds two points on an elliptic curve defined over a finite field of prime order `P`.
///
/// # Parameters
/// - `p1`: A `Point` representing the first point on the elliptic curve.
/// - `p2`: A `Point` representing the second point on the elliptic curve.
///
/// # Returns
/// - `Point`: The resulting point after addition.
fn add_points(p1: G1Point, p2: G1Point) -> G1Point {
    if p1.is_zero() {
        return p2;
    }
    if p2.is_zero() {
        return p1;
    }

    let x1 = p1.x;
    let y1 = p1.y;
    let x2 = p2.x;
    let y2 = p2.y;

    if x1 == x2 && y1 == (FQTrait::prime() - y2) {
        return Default::default(); // Point at infinity
    }

    let mut s = FQTrait::zero();

    if x1 == x2 && y1 == y2 {
        // Point doubling
        s = x1.pow(2) / (y1 * FQTrait::from(2)) * FQTrait::from(3);
    } else {
        // Point addition
        s = (y2 - y1) / (x2 - x1);
    }
    let x3 = s * s - x1 - x2;
    let y3 = s * (x1 - x3) - y1;

    G1Point { x: x3, y: y3 }
}

fn point_double(self: G1Point) -> G1Point {
    if self.x.is_zero() && self.y.is_zero() {
        return self; // Point at infinity
    }
    let x = self.x;
    let y = self.y;

    let m = FQTrait::from(3) * x * x / (FQTrait::from(2) * y);
    let new_x = m.pow(2) - (FQTrait::from(2) * x);

    // Calculate new_y = -m * new_x + m * x - y
    let m_new_x = m * new_x;
    let m_x = m * x;
    let new_y = FQTrait::prime() - m_new_x + m_x - y;
    G1Point { x: new_x, y: new_y }
}

fn multiply(mut point: G1Point, mut scalar: u256) -> G1Point {
    if scalar.is_zero() || point.x.is_zero() && point.y.is_zero() {
        return Default::default();
    }

    let mut result = Default::default();

    if scalar > N / 2 {
        scalar = N - scalar;
        point.y = (FQTrait::prime() - point.y);
    }
    while (!scalar.is_zero()) {
        if !(scalar % 2).is_zero() {
            result = add_points(result, point);
        }
        point = add_points(point, point);
        scalar /= 2;
    };
    result
}

fn cast_point_to_fq12(pt: G1Point) -> G12Point {
    if pt.is_zero() {
        return G12Point { x: FQ12Trait::zero(), y: FQ12Trait::zero() };
    }
    let x = pt.x;
    let y = pt.y;
    let x = FQ12 { coeffs: array![x.n, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
    let y = FQ12 { coeffs: array![y.n, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
    G12Point { x, y }
}

impl G1PointPartialEq of PartialEq<G1Point> {
    #[inline(always)]
    fn eq(lhs: @G1Point, rhs: @G1Point) -> bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    #[inline(always)]
    fn ne(lhs: @G1Point, rhs: @G1Point) -> bool {
        !(lhs == rhs)
    }
}

#[derive(Drop, Default, Debug)]
struct G12Point {
    x: FQ12,
    y: FQ12,
}

