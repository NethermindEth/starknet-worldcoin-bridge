/// The `IVerifier` trait defines the interface for verifying a proof.
///
/// It is implemented by the `Verifier` contract.
#[starknet::interface]
trait IVerifier<TState> {
    /// Verifies the given proof and inputs.
    ///
    /// # Arguments
    ///
    /// * `proof` - The proof to be verified.
    /// * `inputs` - The inputs associated with the proof.
    ///
    /// # Returns
    ///
    /// Returns `true` if the proof is valid, `false` otherwise.
    fn verify_proof(self: @TState, proof: verifier::Proof, inputs: verifier::Input) -> bool;
}

#[starknet::contract]
mod Verifier {
    use bn::traits::FieldOps;
    use bn::curve::groups::ECOperations;
    use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
    use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
    use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
    use bn::curve::pairing;
    use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
    use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
    use verifier::constants::vk;
    use verifier::{Proof, Input};
    use garaga::definitions::{
        G1Point, G2Point, G1G2Pair, u384, bn_bits, bls_bits, MillerLoopResultScalingFactor, E12D,
        BNProcessedPair, BLSProcessedPair, get_p, E12DMulQuotient, G2Line, E12DDefinitions,
    };
    use garaga::groth16::{Groth16Proof, Groth16VerifyingKey}; 

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl VerifierImpl of super::IVerifier<ContractState> {
        /// Verifies the given proof and inputs by performing EC pairings.
        ///
        /// # Arguments
        ///
        /// * `proof` - The proof to be verified.
        /// * `inputs` - The inputs associated with the proof.
        ///
        /// # Returns
        ///
        /// Returns `true` if the proof is valid, `false` otherwise.
        fn verify_proof(self: @ContractState, proof: Proof, inputs: Input) -> bool {
            //self.ec_pairings(proof, inputs)
            
            // Public Inputs
            let a = G1Point {x: proof.a_x.into(), y: proof.a_y.into()};  
            let b = G2Point {x0: proof.b1_x.into(), y0: proof.b1_y.into(), x1: proof.b0_x.into(), y1: proof.b0_y.into()}; 
            let c = G1Point {x: proof.c_x.into(), y: proof.c_y.into()};  

            let input: Array<u256> = array![inputs.root, inputs.signal, inputs.ext_nullifier, inputs.nullifier]; 
            let public_inputs: Span<u256> = input.span(); 
            
            let groth16_proof = Groth16Proof {a, b, c, public_inputs};  

            // Verification Key
            let (alpha, beta, gamma, delta, alpha_beta_miller, ic_0, ic_1, ic_2, ic_3, ic_4) = vk();
            let alpha_beta_miller_loop_result: E12D = E12D {
                w0: alpha_beta_miller.c0.c0.c0.c0.into(),
                w1: alpha_beta_miller.c0.c0.c1.c0.into(),
                w2: alpha_beta_miller.c0.c1.c0.c0.into(),
                w3: alpha_beta_miller.c0.c1.c1.c0.into(),
                w4: alpha_beta_miller.c0.c2.c0.c0.into(),
                w5: alpha_beta_miller.c0.c2.c1.c0.into(),
                w6: alpha_beta_miller.c1.c0.c0.c0.into(),
                w7: alpha_beta_miller.c1.c0.c1.c0.into(),
                w8: alpha_beta_miller.c1.c1.c0.c0.into(),
                w9: alpha_beta_miller.c1.c1.c1.c0.into(),
                w10: alpha_beta_miller.c1.c2.c0.c0.into(),
                w11: alpha_beta_miller.c1.c2.c1.c0.into(),
            };
            let gamma_g2: G2Point = G2Point {
                x0: gamma.x.c0.c0.into(), 
                y0: gamma.y.c0.c0.into(), 
                x1: gamma.x.c1.c0.into(), 
                y1: gamma.y.c1.c0.into()
            }; 

            let delta_g2: G2Point = G2Point {
                x0: delta.x.c0.c0.into(), 
                y0: delta.y.c0.c0.into(), 
                x1: delta.x.c1.c0.into(), 
                y1: delta.y.c1.c0.into()
            }; 

            let verification_key = Groth16VerifyingKey {alpha_beta_miller_loop_result, gamma_g2, delta_g2};
            false
        }
    }


    #[generate_trait]
    impl Private of PrivateTrait {
        /// Performs the EC pairings verification.
        ///
        /// # Arguments
        ///
        /// * `proof` - The proof to be verified.
        /// * `inputs` - The inputs associated with the proof.
        ///
        /// # Returns
        ///
        /// Returns `true` if the proof is valid, `false` otherwise.
        fn ec_pairings(self: @ContractState, proof: Proof, inputs: Input) -> bool {
            // Verification key parameters
            let (_, _, gamma_neg, delta_neg, alphabeta_miller, _, _, _, _, _) = vk();
            // Proof parameters
            let (pi_a, pi_b, pi_c) = self.proof(proof);
            // Compute K = pub_0 + (pub_1 * incl_root) + (pub_2 * nullifier) + (pub_3 * signal) + (pub_4 * ext_nullifier)
            let (root, signal, nullifier, ext_nullifier) = self.inputs(inputs);
            let k = self.public_input_multi_scalar_mul(root, nullifier, signal, ext_nullifier);
            // e(A * B) * e(alpha, -beta) * e(C, -delta) * (K * -gamma) = 1
            let proof = ate_miller_loop(pi_a, pi_b)
                * alphabeta_miller
                * ate_miller_loop(k, gamma_neg)
                * ate_miller_loop(pi_c, delta_neg);

            let proved = proof.final_exponentiation();

            assert!(proved == Fq12Utils::one(), "Verifier::ec_pairings: Invalid proof");
            true
        }

        /// Computes the public input multi-scalar multiplication.
        ///
        /// # Arguments
        ///
        /// * `incl_root` - The inclusion root.
        /// * `nullifier_hash` - The nullifier hash.
        /// * `signal_hash` - The signal hash.
        /// * `ext_nullifier_hash` - The external nullifier hash.
        ///
        /// # Returns
        ///
        /// Returns the result of the multi-scalar multiplication as an `AffineG1` point.
        fn public_input_multi_scalar_mul(
            self: @ContractState,
            incl_root: u256,
            nullifier_hash: u256,
            signal_hash: u256,
            ext_nullifier_hash: u256
        ) -> AffineG1 {
            let (_, _, _, _, _, ic_0, ic_1, ic_2, ic_3, ic_4) = vk();
            // Compute K = pub_0 + (pub_1 * incl_root) + (pub_2 * nullifier) + (pub_3 * signal) + (pub_4 * ext_nullifier)
            let temp0 = ic_1.multiply(incl_root);
            let temp1 = ic_2.multiply(nullifier_hash);
            let temp2 = ic_3.multiply(signal_hash);
            let temp3 = ic_4.multiply(ext_nullifier_hash);

            ic_0.add(temp0).add(temp1).add(temp2).add(temp3)
        }

        /// Extracts the proof parameters from the `Proof` struct.
        ///
        /// # Arguments
        ///
        /// * `proof` - The proof struct containing the proof parameters.
        ///
        /// # Returns
        ///
        /// Returns a tuple of `(AffineG1, AffineG2, AffineG1)` representing the proof parameters.
        fn proof(self: @ContractState, proof: Proof) -> (AffineG1, AffineG2, AffineG1) {
            (
                g1(proof.a_x, proof.a_y),
                g2(proof.b1_x, proof.b0_x, proof.b1_y, proof.b0_y),
                g1(proof.c_x, proof.c_y)
            )
        }

        /// Extracts the input values from the given `Input` struct and returns them as a tuple.
        ///
        /// # Arguments
        ///
        /// * `self` - A reference to the `ContractState` instance.
        /// * `inputs` - The `Input` struct containing the input values.
        ///
        /// # Returns
        ///
        /// A tuple containing the extracted input values:
        /// - `root`: The root value of type `u256`.
        /// - `signal`: The signal value of type `u256`.
        /// - `nullifier`: The nullifier value of type `u256`.
        /// - `ext_nullifier`: The external nullifier value of type `u256`.
        fn inputs(self: @ContractState, inputs: Input) -> (u256, u256, u256, u256) {
            (inputs.root, inputs.signal, inputs.nullifier, inputs.ext_nullifier)
        }
    }
}

