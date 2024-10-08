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
            self.ec_pairings(proof, inputs)
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

