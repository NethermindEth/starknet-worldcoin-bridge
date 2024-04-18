# Groth16 World Coin Bridge Semaphore Verifier

Groth16 verifier written in Cairo 1. Ispiration is taken from the official Ethereum py_ecc library, the official ethereum elliptic curve python library https://github.com/ethereum/py_ecc/tree/main.

The following is the list of the tasks pending and completed, this list might growth or shrink, it will depends on the final pairing function requirements.
Note: the library implementation cover the bare necessities to complete the pairing function.

## LIST OF TASKS
- FQ type:
  - [x] add()
  - [x] sub()
  - [x] mul()
  - [x] div()
  - [x] pow()
  - [x] double()
- FQ12 type: 
  - [] add() 🛠️
  - [x] mul()
- G1Point:
  - [x] add()
  - [x] double
  - [x] scalar mul()
  - [x] is_on_curve()
  - [x] cast_point_to_fq12()
  - [] twist() 🛠️
- G2Point
  - [] twist() 🛠️
  - [] is_on_curve() 🛠️
- G12Point
  - linefunc() 🛠️
- Pairing
  - [] miller_loop() 🛠️
  - [] pairing() 🛠️
- [] Semaphore Verifier Contract 🛠️


