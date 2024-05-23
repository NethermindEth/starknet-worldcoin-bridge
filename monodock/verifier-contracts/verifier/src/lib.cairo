mod semaphore;
mod constants;
// 

#[derive(Copy, Drop, Serde)]
struct Proof {
    a_x: u256,
    a_y: u256,
    b1_x: u256,
    b0_x: u256,
    b1_y: u256,
    b0_y: u256,
    c_x: u256,
    c_y: u256
}

#[derive(Copy, Drop, Serde)]
struct Input {
    root: u256,
    signal: u256,
    ext_nullifier: u256,
    nullifier: u256,
}
