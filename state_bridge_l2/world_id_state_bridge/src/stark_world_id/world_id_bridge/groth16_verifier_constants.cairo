use garaga::definitions::{E12D, G1Point, G2Line, G2Point, u288, u384};
use garaga::groth16::Groth16VerifyingKey;

pub const N_PUBLIC_INPUTS: usize = 4;

pub const vk: Groth16VerifyingKey = Groth16VerifyingKey {
    alpha_beta_miller_loop_result: E12D {
        w0: u288 {
            limb0: 0x38febe9f87f730fa3e5bd174,
            limb1: 0xf763950637a776ef9e248435,
            limb2: 0x29dc2d37c63acbda,
        },
        w1: u288 {
            limb0: 0xa31610a97aa4e4539be919ff,
            limb1: 0xfa4d4bfb72b6a3c002018e97,
            limb2: 0x1968ab971e610fce,
        },
        w2: u288 {
            limb0: 0xee6c1ce3a15313c6f9d57f7e,
            limb1: 0xd37e28396640fcfe5f122aae,
            limb2: 0x210d3763f7a27517,
        },
        w3: u288 {
            limb0: 0x7746ddac185562e756b1b92f,
            limb1: 0x44f8b75638ef5a373f319cd8,
            limb2: 0x51e9605db4edac6,
        },
        w4: u288 {
            limb0: 0xc29e0c2ac434301d671ffa56,
            limb1: 0xa06f1db2d4ca4dd88f979102,
            limb2: 0x1d0126fb7d721e02,
        },
        w5: u288 {
            limb0: 0xed2e022e10acbeb35084dc1,
            limb1: 0xf9de514baee870f114669060,
            limb2: 0x10889a0f300ce96c,
        },
        w6: u288 {
            limb0: 0xeec23aadde92d2dd00e4568e,
            limb1: 0x6d5b4b63667db8f10bd851ab,
            limb2: 0x18f1dd15d2e64c69,
        },
        w7: u288 {
            limb0: 0x2131bad24ea07a033d0bf397,
            limb1: 0xb6312a7f2622146be93b5950,
            limb2: 0x227e61ca055f0ac3,
        },
        w8: u288 {
            limb0: 0xb896f30b06350f012274ebcd,
            limb1: 0xd14298f13a76183170aafe08,
            limb2: 0x302bfd90358d23a0,
        },
        w9: u288 {
            limb0: 0x679d91263798da428fa5ea62,
            limb1: 0x806797d163f4df8b55ec774c,
            limb2: 0x29b72d4ec063face,
        },
        w10: u288 {
            limb0: 0x4dbef45fe0c5a14bef7c4a90,
            limb1: 0xd4ae215c443d0f0768198bc6,
            limb2: 0x2fcc02633e427272,
        },
        w11: u288 {
            limb0: 0x7308cad65773475443cfbd80,
            limb1: 0x972f90a77f1a8aeece6571ff,
            limb2: 0x2d3a570362a9fd7f,
        },
    },
    gamma_g2: G2Point {
        x0: u384 {
            limb0: 0xf75edadd46debd5cd992f6ed,
            limb1: 0x426a00665e5c4479674322d4,
            limb2: 0x1800deef121f1e76,
            limb3: 0x0,
        },
        x1: u384 {
            limb0: 0x35a9e71297e485b7aef312c2,
            limb1: 0x7260bfb731fb5d25f1aa4933,
            limb2: 0x198e9393920d483a,
            limb3: 0x0,
        },
        y0: u384 {
            limb0: 0xc43d37b4ce6cc0166fa7daa,
            limb1: 0x4aab71808dcb408fe3d1e769,
            limb2: 0x12c85ea5db8c6deb,
            limb3: 0x0,
        },
        y1: u384 {
            limb0: 0x70b38ef355acdadcd122975b,
            limb1: 0xec9e99ad690c3395bc4b3133,
            limb2: 0x90689d0585ff075,
            limb3: 0x0,
        },
    },
    delta_g2: G2Point {
        x0: u384 {
            limb0: 0x69e450759142a7159b0a4476,
            limb1: 0xa623957c4f2ea1a0d26f1357,
            limb2: 0x2139a256456825da,
            limb3: 0x0,
        },
        x1: u384 {
            limb0: 0xc01a86690a6645b52f3aa1f,
            limb1: 0x5bcff39c7fa9207cd368444c,
            limb2: 0x168e4fddac50a40d,
            limb3: 0x0,
        },
        y0: u384 {
            limb0: 0xc141710167fcdc0dc931bffd,
            limb1: 0xe601586279bb60f12416a8c,
            limb2: 0x1c3976c9a490dad5,
            limb3: 0x0,
        },
        y1: u384 {
            limb0: 0xe49dcd7ae91aaf1223bc6d63,
            limb1: 0xbc6a7dac67c07051f421904d,
            limb2: 0x28deba4ed0a3b79d,
            limb3: 0x0,
        },
    },
};

pub const ic: [G1Point; 5] = [
    G1Point {
        x: u384 {
            limb0: 0x74c6231a2c34417d34491254,
            limb1: 0x55aae85514122267cd7d16e3,
            limb2: 0x335f514c2acb9b2,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xb90b2e8ed4f7e310c88b97f7,
            limb1: 0xf6d660c6f60f86afedd8a12f,
            limb2: 0x7fa1580c1cc3ed4,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xfc9eb7f932a5229494d6b79,
            limb1: 0xa4b3814128c86e597e1442d,
            limb2: 0x20b781dd0db3b798,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xb111a539c0295518bbab3ca9,
            limb1: 0x5670c7b34854e62c227043a7,
            limb2: 0x17d1cef436eb2f66,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x96ea300d40132b1c2f50299a,
            limb1: 0x74ab7e203a18240e51c9d3c8,
            limb2: 0x260945445b4205f8,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x6866059e403689c01c903fb,
            limb1: 0xe1c482c909302916795f811a,
            limb2: 0x11087a8b76b0f957,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x6a6e70762a939d63dcc52dbf,
            limb1: 0x8ba1469ccb8ac99dcdc7cf74,
            limb2: 0x11d20fd81c0e5cf4,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x8dc049e0a6e72f5efc14293d,
            limb1: 0x7d7bcaace88b3842c42b800d,
            limb2: 0x2d447c5f134eff52,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x6c127b4c799ad4fdd230b87c,
            limb1: 0x73bed4c1b76af48975e66dcf,
            limb2: 0x107cd54a1606a6a8,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xcb86cc09aed6f58a28e530b6,
            limb1: 0xbcc56ebb1c482b99340eaa9b,
            limb2: 0x1a51b81f6c07725e,
            limb3: 0x0,
        },
    },
];


pub const precomputed_lines: [G2Line; 176] = [
    G2Line {
        r0a0: u288 {
            limb0: 0x4d347301094edcbfa224d3d5,
            limb1: 0x98005e68cacde68a193b54e6,
            limb2: 0x237db2935c4432bc,
        },
        r0a1: u288 {
            limb0: 0x6b4ba735fba44e801d415637,
            limb1: 0x707c3ec1809ae9bafafa05dd,
            limb2: 0x124077e14a7d826a,
        },
        r1a0: u288 {
            limb0: 0x49a8dc1dd6e067932b6a7e0d,
            limb1: 0x7676d0000961488f8fbce033,
            limb2: 0x3b7178c857630da,
        },
        r1a1: u288 {
            limb0: 0x98c81278efe1e96b86397652,
            limb1: 0xe3520b9dfa601ead6f0bf9cd,
            limb2: 0x2b17c2b12c26fdd0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x41e45d8ddf01b0ce2219b80e,
            limb1: 0xf83d6d7830bf83ac9b5a7fee,
            limb2: 0x2ecdfec6e56ee8dd,
        },
        r0a1: u288 {
            limb0: 0x582d7c1affedc5fb11146063,
            limb1: 0xb4cf26966ac2d116e2924a15,
            limb2: 0x1b731efe95d45f4e,
        },
        r1a0: u288 {
            limb0: 0x7ca836c5d67b5c25ebdd912d,
            limb1: 0x922f8d686e5f5f3ef1039877,
            limb2: 0x15cfcd9161b807,
        },
        r1a1: u288 {
            limb0: 0x9be7704ad603de9449ef8e11,
            limb1: 0x3c4852c1eb2aa4e8e61bc946,
            limb2: 0x14ec082e197fa9f3,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1b3d578c32d1af5736582972,
            limb1: 0x204fe74db6b371d37e4615ab,
            limb2: 0xce69bdf84ed6d6d,
        },
        r0a1: u288 {
            limb0: 0xfd262357407c3d96bb3ba710,
            limb1: 0x47d406f500e66ea29c8764b3,
            limb2: 0x1e23d69196b41dbf,
        },
        r1a0: u288 {
            limb0: 0x1ec8ee6f65402483ad127f3a,
            limb1: 0x41d975b678200fce07c48a5e,
            limb2: 0x2cad36e65bbb6f4f,
        },
        r1a1: u288 {
            limb0: 0xcfa9b8144c3ea2ab524386f5,
            limb1: 0xd4fe3a18872139b0287570c3,
            limb2: 0x54c8bc1b50aa258,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb5ee22ba52a7ed0c533b7173,
            limb1: 0xbfa13123614ecf9c4853249b,
            limb2: 0x6567a7f6972b7bb,
        },
        r0a1: u288 {
            limb0: 0xcf422f26ac76a450359f819e,
            limb1: 0xc42d7517ae6f59453eaf32c7,
            limb2: 0x899cb1e339f7582,
        },
        r1a0: u288 {
            limb0: 0x9f287f4842d688d7afd9cd67,
            limb1: 0x30af75417670de33dfa95eda,
            limb2: 0x1121d4ca1c2cab36,
        },
        r1a1: u288 {
            limb0: 0x7c4c55c27110f2c9a228f7d8,
            limb1: 0x8f14f6c3a2e2c9d74b347bfe,
            limb2: 0x83ef274ba7913a5,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x268d6cff5d1edb48b6634539,
            limb1: 0xc012d83e50c1d4b0fc26eaa3,
            limb2: 0x1964fabfbc2b74b,
        },
        r0a1: u288 {
            limb0: 0x10444e723c32c61bc7689ce4,
            limb1: 0x3811f2016be8746b4ef207c,
            limb2: 0x14f12f744b5d40db,
        },
        r1a0: u288 {
            limb0: 0xebc993c765a52ff0ec9f6c1a,
            limb1: 0x2620b84e1321f91ea67dd219,
            limb2: 0x304e7ea54fcfe822,
        },
        r1a1: u288 {
            limb0: 0xcc8a5a42661cad828e8d6f36,
            limb1: 0x7c07f2f49656b374b165a14a,
            limb2: 0x1b784644c7b1f636,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x251874993a98404b6e39a2d9,
            limb1: 0x4e366e948499a30904734b71,
            limb2: 0x278892b462cab952,
        },
        r0a1: u288 {
            limb0: 0xb4ce6e3287864b1b6cc95908,
            limb1: 0x3b97b9a38138bfb7e8941e01,
            limb2: 0x11660311f9df7982,
        },
        r1a0: u288 {
            limb0: 0x546ea82f82beb1e10a5b5913,
            limb1: 0xb59a4afe28510936ad7048af,
            limb2: 0x28e3260f9f53faf3,
        },
        r1a1: u288 {
            limb0: 0x50a4e82ab1e56b748de6dd11,
            limb1: 0x518602bd259ec1fe927bc5cf,
            limb2: 0x1107ce47694c163f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xfc23a674d089e9cfdefb1db8,
            limb1: 0x9ddfd61d289b65a9b4254476,
            limb2: 0x1e2f561324ef4447,
        },
        r0a1: u288 {
            limb0: 0xf67a6a9e31f6975b220642ea,
            limb1: 0xccd852893796296e4d1ed330,
            limb2: 0x94ff1987d19b62,
        },
        r1a0: u288 {
            limb0: 0x360c2a5aca59996d24cc1947,
            limb1: 0x66c2d7d0d176a3bc53f386e8,
            limb2: 0x2cfcc62a17fbeecb,
        },
        r1a1: u288 {
            limb0: 0x2ddc73389dd9a9e34168d8a9,
            limb1: 0xae9afc57944748b835cbda0f,
            limb2: 0x12f0a1f8cf564067,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xaa83a69d59f5646676832836,
            limb1: 0xd5feb5ae0bd229da6c868284,
            limb2: 0x7d50196d40e3f97,
        },
        r0a1: u288 {
            limb0: 0x5de3643287f3fc0e925a9305,
            limb1: 0x87a77819d1db0def75315931,
            limb2: 0x21b5f495c0e41d91,
        },
        r1a0: u288 {
            limb0: 0xc9f93cfba1968aacc1cef6e1,
            limb1: 0x9d236b7a4e8dc8b6e6de8437,
            limb2: 0x2af8628a9d956006,
        },
        r1a1: u288 {
            limb0: 0x3494e98afdaa9f75ea70cea4,
            limb1: 0x19acdd5fac7e3d70e0fc846f,
            limb2: 0x2f72d27520ff43a7,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9c963c4bdade6ce3d460b077,
            limb1: 0x1738311feefc76f565e34e8a,
            limb2: 0x1aae0d6c9e9888ad,
        },
        r0a1: u288 {
            limb0: 0x9272581fdf80b045c9c3f0a,
            limb1: 0x3946807b0756e87666798edb,
            limb2: 0x2bf6eeda2d8be192,
        },
        r1a0: u288 {
            limb0: 0x3e957661b35995552fb475de,
            limb1: 0xd8076fa48f93f09d8128a2a8,
            limb2: 0xb6f87c3f00a6fcf,
        },
        r1a1: u288 {
            limb0: 0xcf17d6cd2101301246a8f264,
            limb1: 0x514d04ad989b91e697aa5a0e,
            limb2: 0x175f17bbd0ad1219,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x894bc18cc70ca1987e3b8f9f,
            limb1: 0xd4bfa535181f0f8659b063e3,
            limb2: 0x19168d524164f463,
        },
        r0a1: u288 {
            limb0: 0x850ee8d0e9b58b82719a6e92,
            limb1: 0x9fc4eb75cbb027c137d48341,
            limb2: 0x2b2f8a383d944fa0,
        },
        r1a0: u288 {
            limb0: 0x5451c8974a709483c2b07fbd,
            limb1: 0xd7e09837b8a2a3b78e7fe525,
            limb2: 0x347d96be5e7fa31,
        },
        r1a1: u288 {
            limb0: 0x823f2ba2743ee254e4c18a1e,
            limb1: 0x6a61af5db035c443ed0f8172,
            limb2: 0x1e840eee275d1063,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc8a7b038e3d3853fcadf8715,
            limb1: 0x941e54de6e87b48e5de55c00,
            limb2: 0x33020ac5b35b3c5,
        },
        r0a1: u288 {
            limb0: 0x1b8737bcaa689f57972cd888,
            limb1: 0x79c585c377c37ae54a281da4,
            limb2: 0x2da3ccb9b30ac0f9,
        },
        r1a0: u288 {
            limb0: 0x150181564e23d10043e47b7c,
            limb1: 0x499c131936f107ece098cc85,
            limb2: 0x13c6f912dab7a748,
        },
        r1a1: u288 {
            limb0: 0xe0ddf98938a8c5f8936c616,
            limb1: 0x52b7a959a3235607c569d46e,
            limb2: 0x27ad7f3cec59c31d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1d8430c920a04e2b4bc90988,
            limb1: 0x9b488f50dd913362f36910fc,
            limb2: 0x2ecee540232676b1,
        },
        r0a1: u288 {
            limb0: 0x99694b7e15a4858f8ce60c03,
            limb1: 0x8b2404ed42fd9a7d37b65721,
            limb2: 0xf24a079509215cb,
        },
        r1a0: u288 {
            limb0: 0xa646168188faa1c6d5ee34b,
            limb1: 0x786a2736bea46e36f4359be6,
            limb2: 0x2e53dbac174c299c,
        },
        r1a1: u288 {
            limb0: 0xece309521fa3d0f02516caae,
            limb1: 0xe18195ccdb96f38ef4b1baa,
            limb2: 0x11f466da1b5cb6c7,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x18d630598e58bb5d0102b30e,
            limb1: 0x9767e27b02a8da37411a2787,
            limb2: 0x100a541662b9cd7c,
        },
        r0a1: u288 {
            limb0: 0x4ca7313df2e168e7e5ea70,
            limb1: 0xd49cce6abd50b574f31c2d72,
            limb2: 0x78a2afbf72317e7,
        },
        r1a0: u288 {
            limb0: 0x6d99388b0a1a67d6b48d87e0,
            limb1: 0x1d8711d321a193be3333bc68,
            limb2: 0x27e76de53a010ce1,
        },
        r1a1: u288 {
            limb0: 0x77341bf4e1605e982fa50abd,
            limb1: 0xc5cf10db170b4feaaf5f8f1b,
            limb2: 0x762adef02274807,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8dbf3c55e983a10465b900cd,
            limb1: 0x87f419e497f73ee09c2f8ca7,
            limb2: 0x22a37ce017304a0b,
        },
        r0a1: u288 {
            limb0: 0xab45d733a8c8f4af5bcc20ba,
            limb1: 0x3bcc55fecbcebdf46ce5ed25,
            limb2: 0x5862c742c9270f5,
        },
        r1a0: u288 {
            limb0: 0x487aa2529e65605ceed14d8a,
            limb1: 0x5b2531a48e1f286888aa0742,
            limb2: 0x26951e0979eec3a0,
        },
        r1a1: u288 {
            limb0: 0x5670e7e313a4ad6f95701694,
            limb1: 0x4fbdfe6721bfc3e1fe6b22dd,
            limb2: 0x22a6a616b6a2734c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa137b991ba9048aee9fa0bc7,
            limb1: 0xf5433785c186cd1100ab6b80,
            limb2: 0xab519fd7cf8e7f9,
        },
        r0a1: u288 {
            limb0: 0x90832f45d3398c60aa1a74e2,
            limb1: 0x17f7ac209532723f22a344b,
            limb2: 0x23db979f8481c5f,
        },
        r1a0: u288 {
            limb0: 0x723b0e23c2808a5d1ea6b11d,
            limb1: 0x3030030d26411f84235c3af5,
            limb2: 0x122e78da5509eddb,
        },
        r1a1: u288 {
            limb0: 0xf1718c1e21a9bc3ec822f319,
            limb1: 0xf5ee6dfa3bd3272b2f09f0c7,
            limb2: 0x5a29c1e27616b34,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8ddaff7f1abd730215b2283c,
            limb1: 0x52e1c05040f66b77c16ded17,
            limb2: 0x63c29017d8173cb,
        },
        r0a1: u288 {
            limb0: 0xdb1fec6de057a13de3019e82,
            limb1: 0x360faf5a336aed11ed865075,
            limb2: 0xd6617b955d4eb22,
        },
        r1a0: u288 {
            limb0: 0xe18cfd2d7fab3e9480e688fc,
            limb1: 0x6e5c352463abcaabcdc5012c,
            limb2: 0x3010f3c88d2903d8,
        },
        r1a1: u288 {
            limb0: 0x61be9dcacb27987307f8aae3,
            limb1: 0x91bd9f9f2b8844faaf04ec3e,
            limb2: 0x1f06cb0e8f6a308f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbc1ede480873fceb8739511e,
            limb1: 0xd5a60533bd0ce7869efbc15,
            limb2: 0x182c17d793eba74d,
        },
        r0a1: u288 {
            limb0: 0x83bf38d91876ad8999516bc2,
            limb1: 0x7756322ea3dc079289d51f2d,
            limb2: 0x1d0f6156a89a4244,
        },
        r1a0: u288 {
            limb0: 0x6aba652f197be8f99707b88c,
            limb1: 0xbf94286c245794ea0f562f32,
            limb2: 0x25a358967a2ca81d,
        },
        r1a1: u288 {
            limb0: 0xc028cbff48c01433e8b23568,
            limb1: 0xd2e791f5772ed43b056beba1,
            limb2: 0x83eb38dff4960e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8d2eda57b0049a1eb0ef28ed,
            limb1: 0x96da3a7adb5c6e54ed71bfde,
            limb2: 0x13035d8aed07bb96,
        },
        r0a1: u288 {
            limb0: 0x882f5c682f984bc1bc946371,
            limb1: 0x6d839c238ed0b7a96477902c,
            limb2: 0x78ce79a9d10e585,
        },
        r1a0: u288 {
            limb0: 0xcb4f4030fe35c096a841f766,
            limb1: 0xa117c2413e5a963f91cbc235,
            limb2: 0x19f50a6e14dca3aa,
        },
        r1a1: u288 {
            limb0: 0x1f006e12491c89f8a7020b10,
            limb1: 0xe58e9e7a9fd00c36043e9644,
            limb2: 0x2d5b0c56b856c542,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc2a2b787d8e718e81970db80,
            limb1: 0x5372abeaf56844dee60d6198,
            limb2: 0x131210153a2217d6,
        },
        r0a1: u288 {
            limb0: 0x70421980313e09a8a0e5a82d,
            limb1: 0xf75ca1f68f4b8deafb1d3b48,
            limb2: 0x102113c9b6feb035,
        },
        r1a0: u288 {
            limb0: 0x4654c11d73bda84873de9b86,
            limb1: 0xa67601bca2e595339833191a,
            limb2: 0x1c2b76e439adc8cc,
        },
        r1a1: u288 {
            limb0: 0x9c53a48cc66c1f4d644105f2,
            limb1: 0xa17a18867557d96fb7c2f849,
            limb2: 0x1deb99799bd8b63a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc32026c56341297fa080790c,
            limb1: 0xe23ad2ff283399133533b31f,
            limb2: 0xa6860f5c968f7ad,
        },
        r0a1: u288 {
            limb0: 0x2966cf259dc612c6a4d8957d,
            limb1: 0xfba87ea86054f3db5774a08f,
            limb2: 0xc73408b6a646780,
        },
        r1a0: u288 {
            limb0: 0x6272ce5976d8eeba08f66b48,
            limb1: 0x7dfbd78fa06509604c0cec8d,
            limb2: 0x181ec0eaa6660e45,
        },
        r1a1: u288 {
            limb0: 0x48af37c1a2343555fbf8a357,
            limb1: 0xa7b5e1e20e64d6a9a9ce8e61,
            limb2: 0x1147dcea39a47abd,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7fc39a610445068a1975cd9f,
            limb1: 0x337ffd4f3d89c6e0a1972d,
            limb2: 0x16eafb3958e26852,
        },
        r0a1: u288 {
            limb0: 0x1552faffd7002328d0f7cac2,
            limb1: 0x6afacf7c3b96a56b11a25339,
            limb2: 0x67202e8407bad76,
        },
        r1a0: u288 {
            limb0: 0xd81da43ef0cc4b0aafa79c02,
            limb1: 0x64afa5a33717ba17e6d0e11a,
            limb2: 0x221689dc176c15c6,
        },
        r1a1: u288 {
            limb0: 0x720e6f6edd0b0321749c3c05,
            limb1: 0x60a10928125b5214a011091a,
            limb2: 0x1166ff44fcc9179,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6127ef05d7e24a3e485d6f14,
            limb1: 0x3c9a147fa5fbdc64d45b2cf6,
            limb2: 0x113eb0b565043b14,
        },
        r0a1: u288 {
            limb0: 0xbca2cc0b58ec85bc0808235f,
            limb1: 0x787ca3adc1f52fb9da7ebbe4,
            limb2: 0x2f48c2023ad64703,
        },
        r1a0: u288 {
            limb0: 0x9bef977724adb70704b1ad64,
            limb1: 0xa885327920e2b0ca96ec2a3e,
            limb2: 0xf7b3447dfcf556f,
        },
        r1a1: u288 {
            limb0: 0x914e9d9b305262ecf63d7526,
            limb1: 0x131aea659bbeec5a14a0b573,
            limb2: 0x44e267a4922b805,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x4033c51e6e469818521cd2ae,
            limb1: 0xb71a4629a4696b2759f8e19e,
            limb2: 0x4f5744e29c1eb30,
        },
        r0a1: u288 {
            limb0: 0xa4f47bbc60cb0649dca1c772,
            limb1: 0x835f427106f4a6b897c6cf23,
            limb2: 0x17ca6ea4855756bb,
        },
        r1a0: u288 {
            limb0: 0x7f844a35c7eeadf511e67e57,
            limb1: 0x8bb54fb0b3688cac8860f10,
            limb2: 0x1c7258499a6bbebf,
        },
        r1a1: u288 {
            limb0: 0x10d269c1779f96946e518246,
            limb1: 0xce6fcef6676d0dacd395dc1a,
            limb2: 0x2cf4c6ae1b55d87d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc0245d211d6a2777531e45e9,
            limb1: 0xf162383de91eb69419c19a0f,
            limb2: 0x924d21bb598e7e0,
        },
        r0a1: u288 {
            limb0: 0xd7767ddb0327a6f8b6bf3ced,
            limb1: 0x9643b9aada6f8c8714ff5a90,
            limb2: 0x189673623716f4fe,
        },
        r1a0: u288 {
            limb0: 0xdb1173b2bbc60d6039334ca0,
            limb1: 0x4d11e8d3a74c01cba176b3d8,
            limb2: 0x31a1181e6f9fcf7,
        },
        r1a1: u288 {
            limb0: 0x2209992da6430de52cee6ac1,
            limb1: 0x964f8a6a83bb47b60e13e183,
            limb2: 0xb8233849ec03276,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xab74a6bae36b17b1d2cc1081,
            limb1: 0x904cf03d9d30b1fe9dc71374,
            limb2: 0x14ffdd55685b7d82,
        },
        r0a1: u288 {
            limb0: 0x277f7180b7cf33feded1583c,
            limb1: 0xc029c3968a75b612303c4298,
            limb2: 0x20ef4ba03605cdc6,
        },
        r1a0: u288 {
            limb0: 0xd5a7a27c1baba3791ab18957,
            limb1: 0x973730213d5d70d3e62d6db,
            limb2: 0x24ca121c566eb857,
        },
        r1a1: u288 {
            limb0: 0x9f4c2dea0492f548ae7d9e93,
            limb1: 0xe584b6b251a5227c70c5188,
            limb2: 0x22bcecac2bd5e51b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x340c82974f7221a53fc2f3ac,
            limb1: 0x7146f18cd591d423874996e7,
            limb2: 0xa6d154791056f46,
        },
        r0a1: u288 {
            limb0: 0x70894ea6418890d53b5ee12a,
            limb1: 0x882290cb53b795b0e7c8c208,
            limb2: 0x1b5777dc18b2899b,
        },
        r1a0: u288 {
            limb0: 0x99a0e528d582006a626206b6,
            limb1: 0xb1cf825d80e199c5c9c795b5,
            limb2: 0x2a97495b032f0542,
        },
        r1a1: u288 {
            limb0: 0xc7cf5b455d6f3ba73debeba5,
            limb1: 0xbb0a01235687223b7b71d0e5,
            limb2: 0x250024ac44c35e3f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x48d384b633831d0cf7d8f88d,
            limb1: 0x5b392afc7f5bc5fbf83a25c8,
            limb2: 0x12ea9a48b63e52d8,
        },
        r0a1: u288 {
            limb0: 0xfb9001e33ae3444234e696b0,
            limb1: 0x7ff304b4fa3a9361576917c0,
            limb2: 0x1cc0fff87748b457,
        },
        r1a0: u288 {
            limb0: 0xe7cc01228abcd67c8634fe80,
            limb1: 0xc1a491161e19f3b4afcd5995,
            limb2: 0x156de74b93986e4,
        },
        r1a1: u288 {
            limb0: 0xa45725cc838d56c53a8bc2f2,
            limb1: 0x3e8ed4b455c6c45400c3c1f0,
            limb2: 0x10a4c09132c93ae9,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6ebcaa2d25a8e444e24aea6f,
            limb1: 0x6acce49de641f20e4dbadd15,
            limb2: 0x11bff28e3ff95339,
        },
        r0a1: u288 {
            limb0: 0xe5db84107e3caca4b5870ef5,
            limb1: 0x64829ca9d0ca98ef2beee00c,
            limb2: 0x43c7aaa50726aa,
        },
        r1a0: u288 {
            limb0: 0xf0713b2f5850089d2a62478c,
            limb1: 0xcc2f9194287782303c7175aa,
            limb2: 0x2d740cc53418070a,
        },
        r1a1: u288 {
            limb0: 0x9c6719b8a60e190418ca85b7,
            limb1: 0xb8f2cfcf828dec98f7a6bff0,
            limb2: 0x18c01927fc7ad8b6,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xccf841cf5c1cf8f4a0485e28,
            limb1: 0xb5077662d0ce9d755af1446b,
            limb2: 0x2b08658e9d5ba5cb,
        },
        r0a1: u288 {
            limb0: 0x6ce62184a15685babd77f27f,
            limb1: 0x5ff9bb7d74505b0542578299,
            limb2: 0x7244563488bab2,
        },
        r1a0: u288 {
            limb0: 0xec778048d344ac71275d961d,
            limb1: 0x1273984019753000ad890d33,
            limb2: 0x27c2855e60d361bd,
        },
        r1a1: u288 {
            limb0: 0xa7a0071e22af2f3a79a12da,
            limb1: 0xc84a6fd41c20759ff6ff169a,
            limb2: 0x23e7ef2a308e49d1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xee6ccc9a006480ffab3883f8,
            limb1: 0xab3bf4ab37380d2d758b051a,
            limb2: 0xdb62031f844f5f9,
        },
        r0a1: u288 {
            limb0: 0x4d6d8dc6b643ab8bec3385bc,
            limb1: 0x5a84b84ff77677543cce928,
            limb2: 0x2df98979f35cde7,
        },
        r1a0: u288 {
            limb0: 0x629cd0f4ed2bdc54d92b74d2,
            limb1: 0xec487fdfae44ec8fb5efb031,
            limb2: 0x1861b055b21ca3f8,
        },
        r1a1: u288 {
            limb0: 0x1bb19c1ba3caf6c1a3e61556,
            limb1: 0x337657c35e040bfdb4085f5d,
            limb2: 0x2d40389e74faa2c3,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7105024c431a33683d9d0b9d,
            limb1: 0x12e23637b641ab0e5b322ad8,
            limb2: 0x2918e9e08c764c28,
        },
        r0a1: u288 {
            limb0: 0x26384979d1f5417e451aeabf,
            limb1: 0xacfb499e362291d0b053bbf6,
            limb2: 0x2a6ad1a1f7b04ef6,
        },
        r1a0: u288 {
            limb0: 0xba4db515be70c384080fc9f9,
            limb1: 0x5a983a6afa9cb830fa5b66e6,
            limb2: 0x8cc1fa494726a0c,
        },
        r1a1: u288 {
            limb0: 0x59c9af9399ed004284eb6105,
            limb1: 0xef37f66b058b4c971d9c96b0,
            limb2: 0x2c1839afde65bafa,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x79de88e512837e3d824d1217,
            limb1: 0x3709d20474901198485bef18,
            limb2: 0xbe5409ddf4b4881,
        },
        r0a1: u288 {
            limb0: 0x75112d8530d606bcad651fec,
            limb1: 0x329584a96369215400d8aa3e,
            limb2: 0x4d5c9b33eec4669,
        },
        r1a0: u288 {
            limb0: 0x123b64bbf1db03f288e943f3,
            limb1: 0xd1f2a9179a64b31a371c8bd7,
            limb2: 0x619e74aa533aa9f,
        },
        r1a1: u288 {
            limb0: 0x4cbe3520a30deb1b1dcc313d,
            limb1: 0xc22762e0beb9fc01271c498d,
            limb2: 0x1b808fc8396376c8,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6bf13a27b0f4eb6657abc4b,
            limb1: 0xf78d57f089bffdf07c676bb3,
            limb2: 0x228e4aefbdd738df,
        },
        r0a1: u288 {
            limb0: 0x4f41a40b04ec964619823053,
            limb1: 0xfa3fb44f4a80641a9bb3bc09,
            limb2: 0x29bf29a3d071ec4b,
        },
        r1a0: u288 {
            limb0: 0x83823dcdff02bdc8a0e6aa03,
            limb1: 0x79ac92f113de29251cd73a98,
            limb2: 0x1ccdb791718d144,
        },
        r1a1: u288 {
            limb0: 0xa074add9d066db9a2a6046b6,
            limb1: 0xef3a70034497456c7d001a5,
            limb2: 0x27d09562d815b4a6,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x120c2feb3e132a40f6861170,
            limb1: 0x7ced1e70cfa83031f3230b18,
            limb2: 0x291be17495f748d9,
        },
        r0a1: u288 {
            limb0: 0xdbe84d88771ae166a5367993,
            limb1: 0x759b32c60e9dc8780b95ad53,
            limb2: 0x1385286125eceb1b,
        },
        r1a0: u288 {
            limb0: 0x8c9833ea44474b069188304c,
            limb1: 0xa2ca8fdd6b5ceb291e79735c,
            limb2: 0x4be011ff21b5588,
        },
        r1a1: u288 {
            limb0: 0xb04c82fdea3a57c8cebf1096,
            limb1: 0xfeae5022ba810df64d28b977,
            limb2: 0x182d7ab48f744ec1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x87a44d343cc761056f4f2eae,
            limb1: 0x18016f16818253360d2c8adf,
            limb2: 0x1bcd5c6e597d735e,
        },
        r0a1: u288 {
            limb0: 0x593d7444c376f6d69289660b,
            limb1: 0x1d6d97020b59cf2e4b38be4f,
            limb2: 0x17133b62617f63a7,
        },
        r1a0: u288 {
            limb0: 0x88cac99869bb335ec9553a70,
            limb1: 0x95bcfa7f7c0b708b4d737afc,
            limb2: 0x1eec79b9db274c09,
        },
        r1a1: u288 {
            limb0: 0xe465a53e9fe085eb58a6be75,
            limb1: 0x868e45cc13e7fd9d34e11839,
            limb2: 0x2b401ce0f05ee6bb,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x83f48fbac5c1b94486c2d037,
            limb1: 0xf95d9333449543de78c69e75,
            limb2: 0x7bca8163e842be7,
        },
        r0a1: u288 {
            limb0: 0x60157b2ff6e4d737e2dac26b,
            limb1: 0x30ab91893fcf39d9dcf1b89,
            limb2: 0x29a58a02490d7f53,
        },
        r1a0: u288 {
            limb0: 0x520f9cb580066bcf2ce872db,
            limb1: 0x24a6e42c185fd36abb66c4ba,
            limb2: 0x309b07583317a13,
        },
        r1a1: u288 {
            limb0: 0x5a4c61efaa3d09a652c72471,
            limb1: 0xfcb2676d6aa28ca318519d2,
            limb2: 0x1405483699afa209,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xaabccc7fb5fdf4169ceb7a7b,
            limb1: 0xa27749cedbbee97874d738d9,
            limb2: 0xc6418c8c262ce52,
        },
        r0a1: u288 {
            limb0: 0x3a87957202cb6a11079fd23b,
            limb1: 0x6153a32bbd2ee4d60b0d1404,
            limb2: 0xc26524b7e436a5e,
        },
        r1a0: u288 {
            limb0: 0x1e1899e8dde1da5befab8e59,
            limb1: 0x7306b8df2a413286dc5e3255,
            limb2: 0x2b947d351462f925,
        },
        r1a1: u288 {
            limb0: 0x19858b3e22bbe98e5710b467,
            limb1: 0x238d14daf3ba3527b22815fd,
            limb2: 0x18f926e497864d5c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6c7551195109176be8acc0ed,
            limb1: 0x9164a2933ae31fe9508cf991,
            limb2: 0x280af08249257270,
        },
        r0a1: u288 {
            limb0: 0x5be885634de3055256656623,
            limb1: 0x1b26d123b2afc5c7b4e6e021,
            limb2: 0x160141731f8f60de,
        },
        r1a0: u288 {
            limb0: 0xd1dac0ed84ed1e29a13265f7,
            limb1: 0x6acc36ccb612ba5b4579afbe,
            limb2: 0x27fc1d6197875731,
        },
        r1a1: u288 {
            limb0: 0xfb8008403ae8767368a82386,
            limb1: 0x3c125d63890af8300d727771,
            limb2: 0x1befa4624bc4ae2f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbfdfdae86101e29da3e869b8,
            limb1: 0xf969a9b961a28b872e56aac2,
            limb2: 0x1afdc719440d90f0,
        },
        r0a1: u288 {
            limb0: 0xee43c995686f13baa9b07266,
            limb1: 0xbfa387a694c641cceee4443a,
            limb2: 0x104d8c02eb7f60c8,
        },
        r1a0: u288 {
            limb0: 0x8d451602b3593e798aecd7fb,
            limb1: 0x69ffbefe7c5ac2cf68e8691e,
            limb2: 0x2ea064a1bc373d28,
        },
        r1a1: u288 {
            limb0: 0x6e7a663073bfe88a2b02326f,
            limb1: 0x5faadb36847ca0103793fa4a,
            limb2: 0x26c09a8ec9303836,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9251e7d7e747269962c5d43b,
            limb1: 0x3dbf400583d7f1bf7d79905b,
            limb2: 0x153764a0eb38e594,
        },
        r0a1: u288 {
            limb0: 0x7c6b6aa2f9c8bc886bb71769,
            limb1: 0x20cab097ff1ecf1e4e1f5279,
            limb2: 0x1c730b1e5c13d169,
        },
        r1a0: u288 {
            limb0: 0xab9c5e15145c6d0c831a6b3a,
            limb1: 0x67abd59b9dd47d8862f793b4,
            limb2: 0x231ff4e8619a1594,
        },
        r1a1: u288 {
            limb0: 0xa3fce1285684d5fde9bcd629,
            limb1: 0x9dba9251b7b2d9ed503a06dd,
            limb2: 0x2e643dd0cef3196b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3d038747ebac16adc1c50bdd,
            limb1: 0xe3706a783e99f73ac742aa1a,
            limb2: 0x17eac23b00b545ff,
        },
        r0a1: u288 {
            limb0: 0xdc25ff0bd02abcbe502c4e37,
            limb1: 0x39b92e6ebb65e5f2d8504f90,
            limb2: 0x2415b5f61301dff6,
        },
        r1a0: u288 {
            limb0: 0x9cdcb2146d15f37900db82ac,
            limb1: 0x96c3940e2f5c5f8198fadee3,
            limb2: 0x2f662ea79b473fc2,
        },
        r1a1: u288 {
            limb0: 0xc0fb95686de65e504ed4c57a,
            limb1: 0xec396c7c4275d4e493b00713,
            limb2: 0x106d2aab8d90d517,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7be6a55fd859932572762b9c,
            limb1: 0x4ab6ce3aac021bb506f0b5c4,
            limb2: 0x2324dfe3657cf319,
        },
        r0a1: u288 {
            limb0: 0x7646a501094d75ded21dc8d7,
            limb1: 0x342a12ee90937d905ec42b32,
            limb2: 0x28f31a079548ca3,
        },
        r1a0: u288 {
            limb0: 0x1cf5b6ec48afbf7e900d7c40,
            limb1: 0xc05f5abbc9235bef6fcb43e1,
            limb2: 0x4665d2603ed1149,
        },
        r1a1: u288 {
            limb0: 0xa87d498b1a4a936b74447743,
            limb1: 0xee0f035a2dab5a4cff0f6704,
            limb2: 0x23e1455af4d55255,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x49bbb4d856921e3177c0b5bf,
            limb1: 0x76d84d273694e662bdd5d364,
            limb2: 0xea5dc611bdd369d,
        },
        r0a1: u288 {
            limb0: 0x9e9fc3adc530fa3c5c6fd7fe,
            limb1: 0x114bb0c0e8bd247da41b3883,
            limb2: 0x6044124f85d2ce,
        },
        r1a0: u288 {
            limb0: 0xa6e604cdb4e40982a97c084,
            limb1: 0xef485caa56c7820be2f6b11d,
            limb2: 0x280de6387dcbabe1,
        },
        r1a1: u288 {
            limb0: 0xcaceaf6df5ca9f8a18bf2e1e,
            limb1: 0xc5cce932cc6818b53136c142,
            limb2: 0x12f1cd688682030c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x37497c23dcf629df58a5fa12,
            limb1: 0x4fcd5534ae47bded76245ac9,
            limb2: 0x1715ab081e32ac95,
        },
        r0a1: u288 {
            limb0: 0x856275471989e2c288e3c83,
            limb1: 0xb42d81a575b89b127a7821a,
            limb2: 0x5fa75a0e4ae3118,
        },
        r1a0: u288 {
            limb0: 0xeb22351e8cd345c23c0a3fef,
            limb1: 0x271feb16d4b47d2267ac9d57,
            limb2: 0x258f9950b9a2dee5,
        },
        r1a1: u288 {
            limb0: 0xb5f75468922dc025ba7916fa,
            limb1: 0x7e24515de90edf1bde4edd9,
            limb2: 0x289145b3512d4d81,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb80134f84a292e4103817c00,
            limb1: 0x1aa26dbd80e6b29e0c4d34ee,
            limb2: 0xe864beda3f6238,
        },
        r0a1: u288 {
            limb0: 0x9d8b4e068aa964e9b347cee5,
            limb1: 0xed0f54cd3cbfcf59475f5c2e,
            limb2: 0x1c53f003c951e11c,
        },
        r1a0: u288 {
            limb0: 0x974cb4be7258a915eac837bc,
            limb1: 0xc7a64a5ecb6df9be8473f289,
            limb2: 0x964a05fce019d45,
        },
        r1a1: u288 {
            limb0: 0xf29ed500f3927cbc54de129,
            limb1: 0x64daf26e152545a73b41450,
            limb2: 0x116a6f41a3f34645,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6381f0f4186f8c6b12527a41,
            limb1: 0xf9b8a06dd876a324cb6d6dfd,
            limb2: 0x19050e3d7df7ca93,
        },
        r0a1: u288 {
            limb0: 0xd576ed559314df238895d587,
            limb1: 0x832a3d578ee34ec532149717,
            limb2: 0x23ed305e08daf55b,
        },
        r1a0: u288 {
            limb0: 0x1ff9e457d36dde53d44347b7,
            limb1: 0x1c4925f3e43ed36485a6c9cc,
            limb2: 0x1421e6123ce9d1bf,
        },
        r1a1: u288 {
            limb0: 0x50dcfc096d145ad04d284ca0,
            limb1: 0x6dc8cf03fece8ae01fa1dc25,
            limb2: 0x1cc896d56132429f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x95b7b32bcc3119c64a62a8de,
            limb1: 0xe07184496f17bbd59a4b7bbd,
            limb2: 0x1708c536fd78b531,
        },
        r0a1: u288 {
            limb0: 0xfa85b5778c77166c1523a75e,
            limb1: 0x89a00c53309a9e525bef171a,
            limb2: 0x2d2287dd024e421,
        },
        r1a0: u288 {
            limb0: 0x31fd0884eaf2208bf8831e72,
            limb1: 0x537e04ea344beb57ee645026,
            limb2: 0x23c7f99715257261,
        },
        r1a1: u288 {
            limb0: 0x8c38b3aeea525f3c2d2fdc22,
            limb1: 0xf838a99d9ec8ed6dcec6a2a8,
            limb2: 0x2973d5159ddc479a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3f058d8c63fd905d3ca29b42,
            limb1: 0x1f0a90982cc68e4ddcd83e57,
            limb2: 0x240aeaae0783fbfa,
        },
        r0a1: u288 {
            limb0: 0xedfee81d80da310fdf0d0d8,
            limb1: 0xc2208e6de8806cf491bd74d4,
            limb2: 0xb7318be62a476af,
        },
        r1a0: u288 {
            limb0: 0x3c6920c8a24454c634f388fe,
            limb1: 0x23328a006312a722ae09548b,
            limb2: 0x1d2f1c58b80432e2,
        },
        r1a1: u288 {
            limb0: 0xb72980574f7a877586de3a63,
            limb1: 0xcd773b87ef4a29c16784c5ae,
            limb2: 0x1f812c7e22f339c5,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3c488aba00da6f4de30b4f51,
            limb1: 0xadc43a061a80f8a461f6ed29,
            limb2: 0x2a66eeb22ba8871b,
        },
        r0a1: u288 {
            limb0: 0xa1fe455acb51a9c73ec199cc,
            limb1: 0x54ccbc164bcdf43bdc22198e,
            limb2: 0x1f2ab80840a91846,
        },
        r1a0: u288 {
            limb0: 0x977d64074e00bcdacf9b10ce,
            limb1: 0x178fae8038ad18556e3b42fc,
            limb2: 0x10a97142c9d9bbbd,
        },
        r1a1: u288 {
            limb0: 0xf76ca57ad5afa471a32fee6e,
            limb1: 0x57a16713ac7d3e0d73ea8a1b,
            limb2: 0x12bbb8b5521640e2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb65d76ce3f1d7204cf6bf389,
            limb1: 0x84615df0e2b096a312f7e9c8,
            limb2: 0x214c75a98603da3a,
        },
        r0a1: u288 {
            limb0: 0xe1664f8ff4d33e1cdaa31ca,
            limb1: 0xa8d38d01ec6be6a5c249eeda,
            limb2: 0x14d738ba58ce1803,
        },
        r1a0: u288 {
            limb0: 0xa8944e00a973e9d669ffa581,
            limb1: 0x31d07595eae067fed13acb69,
            limb2: 0x1507d57f6fce7ffe,
        },
        r1a1: u288 {
            limb0: 0xa54526b3ef35ca28724294fd,
            limb1: 0xb263a54bf0eda6df600f17ce,
            limb2: 0xb1fdbe6b35a8eee,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xfeebe92941f95b6ea1d095bb,
            limb1: 0x9c7962eb8bbeb95a9ca7cf50,
            limb2: 0x290bdaf3b9a08dc3,
        },
        r0a1: u288 {
            limb0: 0x686cfa11c9d4b93675495599,
            limb1: 0xb1d69e17b4b5ebf64f0d51e1,
            limb2: 0x2c18bb4bdc2e9567,
        },
        r1a0: u288 {
            limb0: 0x17419b0f6a04bfc98d71527,
            limb1: 0x80eba6ff02787e3de964a4d1,
            limb2: 0x26087bb100e7ff9f,
        },
        r1a1: u288 {
            limb0: 0x17c4ee42c3f612c43a08f689,
            limb1: 0x7276bdda2df6d51a291dba69,
            limb2: 0x40a7220ddb393e1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc000056c706af84f164c1677,
            limb1: 0xb3f35f6ff9f05cd3d512b8e2,
            limb2: 0x28f66cdfea7f598f,
        },
        r0a1: u288 {
            limb0: 0x2c0a9a09e7d5ee6e34c0136a,
            limb1: 0x437f7c20468b59277d0b9275,
            limb2: 0x1a35e041ebc074e7,
        },
        r1a0: u288 {
            limb0: 0xb73c7b267e9822a6c0639d28,
            limb1: 0xccdda746978000bccf2977c3,
            limb2: 0x2fd6842d6f897bf0,
        },
        r1a1: u288 {
            limb0: 0xbeed17302fb7d860dc70e8b2,
            limb1: 0x4856e276418ef8cb56f20ea7,
            limb2: 0x2df35e9ec4253550,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x830d777c19040571a1d72fd0,
            limb1: 0x651b2c6b8c292020817a633f,
            limb2: 0x268af1e285bc59ff,
        },
        r0a1: u288 {
            limb0: 0xede78baa381c5bce077f443d,
            limb1: 0x540ff96bae21cd8b9ae5438b,
            limb2: 0x12a1fa7e3b369242,
        },
        r1a0: u288 {
            limb0: 0x797c0608e5a535d8736d4bc5,
            limb1: 0x375faf00f1147656b7c1075f,
            limb2: 0xda60fab2dc5a639,
        },
        r1a1: u288 {
            limb0: 0x610d26085cfbebdb30ce476e,
            limb1: 0x5bc55890ff076827a09e8444,
            limb2: 0x14272ee2d25f20b7,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x707cea95e252c3cb7681c169,
            limb1: 0xe0e8385a184e413ddebb1cf4,
            limb2: 0x5c972eced3e8952,
        },
        r0a1: u288 {
            limb0: 0x60da245ed00c2c47ec9a2e24,
            limb1: 0x5db6e13d85094fec5336644e,
            limb2: 0x246d8c3bba6bf1e0,
        },
        r1a0: u288 {
            limb0: 0xfe1e69d06b8fb56ccf412c37,
            limb1: 0xf6da40361a56e31e82263180,
            limb2: 0xef757011c56f2ea,
        },
        r1a1: u288 {
            limb0: 0x3b06af2e2b057be5932de1dd,
            limb1: 0xc04419124caa119c751c0f4d,
            limb2: 0x2d4fd07d0caa527d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd6862e1a4ca3b2baf6f8d8aa,
            limb1: 0x96f9066dded3a3d899025af4,
            limb2: 0x1a98af9f0d48fd3,
        },
        r0a1: u288 {
            limb0: 0x276b417cc61ea259c114314e,
            limb1: 0x464399e5e0037b159866b246,
            limb2: 0x12cc97dcf32896b5,
        },
        r1a0: u288 {
            limb0: 0xef72647f4c2d08fc038c4377,
            limb1: 0x34883cea19be9a490a93cf2b,
            limb2: 0x10d01394daa61ed0,
        },
        r1a1: u288 {
            limb0: 0xdf345239ece3acaa62919643,
            limb1: 0x914780908ece64e763cca062,
            limb2: 0xee2a80dbd2012a3,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1d5a31f4d08a0ebf7e071e00,
            limb1: 0xcd1244dd95dd30005f531f81,
            limb2: 0xb4cb469a2dcf4f1,
        },
        r0a1: u288 {
            limb0: 0x7c5938adaf38b355092de1f1,
            limb1: 0x292ab08995b293abfcba14b,
            limb2: 0x1fd126a2b9f37c67,
        },
        r1a0: u288 {
            limb0: 0x6e9d352b02a7cb771fcc33f9,
            limb1: 0x7754d8536eefda2025a07340,
            limb2: 0x1840289291c35a72,
        },
        r1a1: u288 {
            limb0: 0xe85f465417b7bd758c547b2e,
            limb1: 0xf7f703c3bc55ff8a01fa9365,
            limb2: 0xfa301227880a841,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7a49fbc0493b44d8c4ca0ff4,
            limb1: 0xd784b16dc052be0eb0f2afa2,
            limb2: 0xec53b24e4183f40,
        },
        r0a1: u288 {
            limb0: 0xd83edba8a083916184bf1a9c,
            limb1: 0x46f539d14b9d0a264c0f994d,
            limb2: 0x9eb4da56e8c01d9,
        },
        r1a0: u288 {
            limb0: 0x455b3d425b9b35ca23c319f4,
            limb1: 0x3857d21dd0505bb390934433,
            limb2: 0x29b0906972e81bbd,
        },
        r1a1: u288 {
            limb0: 0x1ca256526e37671d9a2f9fa,
            limb1: 0x196ebd943efd48e4a14413cc,
            limb2: 0x2853236cdc163240,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb03b05e5ebeab2be5a17c088,
            limb1: 0x418a17bbbd2604860f9e1079,
            limb2: 0x24a3c64969b7169c,
        },
        r0a1: u288 {
            limb0: 0x60a890b4a652de88cecacf11,
            limb1: 0xeb3062e9e808668ff74393ac,
            limb2: 0x2c3cc5e62fa2b55b,
        },
        r1a0: u288 {
            limb0: 0xd0c79504ccc8134e3e1a013c,
            limb1: 0x815f49166d810b85821cf3db,
            limb2: 0x25f42f5a780123c9,
        },
        r1a1: u288 {
            limb0: 0xcfc1255cca8598fec05da4ae,
            limb1: 0x8ab1a086c15df44aa5d22520,
            limb2: 0x180ffb3872b1417e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa4058149e82ea51362b79be4,
            limb1: 0x734eba2621918a820ae44684,
            limb2: 0x110a314a02272b1,
        },
        r0a1: u288 {
            limb0: 0xe2b43963ef5055df3c249613,
            limb1: 0x409c246f762c0126a1b3b7b7,
            limb2: 0x19aa27f34ab03585,
        },
        r1a0: u288 {
            limb0: 0x179aad5f620193f228031d62,
            limb1: 0x6ba32299b05f31b099a3ef0d,
            limb2: 0x157724be2a0a651f,
        },
        r1a1: u288 {
            limb0: 0xa33b28d9a50300e4bbc99137,
            limb1: 0x262a51847049d9b4d8cea297,
            limb2: 0x189acb4571d50692,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xff7abba7a4c34f4395df09d4,
            limb1: 0x218dfdcb06ac84493e7e4022,
            limb2: 0x22ea6f59451f6768,
        },
        r0a1: u288 {
            limb0: 0x6a05a6a202204044b8c21168,
            limb1: 0x9f92c34959eb74f93c5bac36,
            limb2: 0x1d04f6b5aa7a8d78,
        },
        r1a0: u288 {
            limb0: 0x4fcf9930a28da97e0d73d84b,
            limb1: 0x683113086f2ebc194d28f178,
            limb2: 0x18b62b170c2a46a3,
        },
        r1a1: u288 {
            limb0: 0x9f3969616b651a28e5c52ffe,
            limb1: 0x5b770cdfe4896ba6212b69a1,
            limb2: 0x2b3c0e18b3fe7c57,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x29bd4381ae4afc677ee37ed6,
            limb1: 0x29ed43453f9a008d9176f004,
            limb2: 0x24134eb915104f43,
        },
        r0a1: u288 {
            limb0: 0x81597f82bb67e90a3e72bdd2,
            limb1: 0xab3bbde5f7bbb4df6a6b5c19,
            limb2: 0x19ac61eea40a367c,
        },
        r1a0: u288 {
            limb0: 0xe30a79342fb3199651aee2fa,
            limb1: 0xf500f028a73ab7b7db0104a3,
            limb2: 0x808b50e0ecb5e4d,
        },
        r1a1: u288 {
            limb0: 0x55f2818453c31d942444d9d6,
            limb1: 0xf6dd80c71ab6e893f2cf48db,
            limb2: 0x13c3ac4488abd138,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x93798ce063d6717ac907c2f6,
            limb1: 0xb59881952e6d1239e5f826ed,
            limb2: 0x93851b5cfb36625,
        },
        r0a1: u288 {
            limb0: 0xa0d8fae4ff0333a613170e4c,
            limb1: 0xfbf128b5c43ccf3a6782642f,
            limb2: 0x17c541e981bd7b1,
        },
        r1a0: u288 {
            limb0: 0x6bcd87bfd9ff9b8be3740d7a,
            limb1: 0x8b72c5a5fa7221850e4d6ff8,
            limb2: 0x1009ef5f287d95ba,
        },
        r1a1: u288 {
            limb0: 0x565c2505d7be82c8a1b23f4d,
            limb1: 0xfef9716bef74f1aa1ea46d17,
            limb2: 0x1560c81c15178e6e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd1464269bbeafa546f559b8f,
            limb1: 0xab7f7dcd1ac32b86979471cf,
            limb2: 0x6a38256ee96f113,
        },
        r0a1: u288 {
            limb0: 0xf14d50984e65f9bc41df4e7e,
            limb1: 0x350aff9be6f9652ad441a3ad,
            limb2: 0x1b1e60534b0a6aba,
        },
        r1a0: u288 {
            limb0: 0x9e98507da6cc50a56f023849,
            limb1: 0xcf8925e03f2bb5c1ba0962dd,
            limb2: 0x2b18961810a62f87,
        },
        r1a1: u288 {
            limb0: 0x3a4c61b937d4573e3f2da299,
            limb1: 0x6f4c6c13fd90f4edc322796f,
            limb2: 0x13f4e99b6a2f025e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa262e49b4c8ee4b5f0cba0a0,
            limb1: 0x28ebf49556706e6f25b94701,
            limb2: 0x241f3fe1cd7e55c1,
        },
        r0a1: u288 {
            limb0: 0xb485818291571e99f2a1fe7b,
            limb1: 0x52a81004a74f2c0b15ded165,
            limb2: 0x93edec7fa8cf1b5,
        },
        r1a0: u288 {
            limb0: 0x26947fbbec8cfa64afacad8e,
            limb1: 0xee7406c45ed9b14f6072bfe,
            limb2: 0x13df45bee0693c65,
        },
        r1a1: u288 {
            limb0: 0xccc6a97f916667868dded24f,
            limb1: 0x27d468a6f39f1639c96e87ed,
            limb2: 0x2ffb01fe95ed69e8,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe0115a79120ae892a72f3dcb,
            limb1: 0xec67b5fc9ea414a4020135f,
            limb2: 0x1ee364e12321904a,
        },
        r0a1: u288 {
            limb0: 0xa74d09666f9429c1f2041cd9,
            limb1: 0x57ffe0951f863dd0c1c2e97a,
            limb2: 0x154877b2d1908995,
        },
        r1a0: u288 {
            limb0: 0xcbe5e4d2d2c91cdd4ccca0,
            limb1: 0xe6acea145563a04b2821d120,
            limb2: 0x18213221f2937afb,
        },
        r1a1: u288 {
            limb0: 0xfe20afa6f6ddeb2cb768a5ae,
            limb1: 0x1a3b509131945337c3568fcf,
            limb2: 0x127b5788263a927e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6c4e048f56402d783bb6dc90,
            limb1: 0x7a8ccc6f44fe3c0a66bd8d2c,
            limb2: 0x9a51eb8198e169a,
        },
        r0a1: u288 {
            limb0: 0xf073032620ae9ff8709b4330,
            limb1: 0xb6b0aa4ba81e3ee11c82aac,
            limb2: 0x14edebedec6e8766,
        },
        r1a0: u288 {
            limb0: 0xb1c48b29208c71e7f5275d75,
            limb1: 0x496d17dad6d0273aa91d2524,
            limb2: 0x2aec469d374bc0b4,
        },
        r1a1: u288 {
            limb0: 0x441af94386793a2affb67147,
            limb1: 0xcbf0956fc520057595e1ac3b,
            limb2: 0x109fad0dd9d69e8a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe7c658aecdab4db3c83f7927,
            limb1: 0xfbf162264ca04ee50c70bde8,
            limb2: 0x2a20f4565b7ff885,
        },
        r0a1: u288 {
            limb0: 0x45b1c2f0a1226361f42683c0,
            limb1: 0x9acdd892c48c08de047296bc,
            limb2: 0x27836373108925d4,
        },
        r1a0: u288 {
            limb0: 0xc0ea9294b345e6d4892676a7,
            limb1: 0xcba74eca77086af245d1606e,
            limb2: 0xf20edac89053e72,
        },
        r1a1: u288 {
            limb0: 0x4c92a28f2779a527a68a938c,
            limb1: 0x3a1c3c55ff9d20eac109fab3,
            limb2: 0x21c4a8c524b1ee7d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x51b73eeb856b64be01a10042,
            limb1: 0x8a7ccee92de9e2b09bef4267,
            limb2: 0x77feea3c210a3e2,
        },
        r0a1: u288 {
            limb0: 0x25c30bbffa797a6a3be9fe19,
            limb1: 0x8c8f033c020b58948b9b5308,
            limb2: 0x2e8133305cc6cdff,
        },
        r1a0: u288 {
            limb0: 0x2fcfacdd3831d5b8a482da7b,
            limb1: 0x87fc8d5dccd92b16e6c7f63,
            limb2: 0xc81d9c87a135c61,
        },
        r1a1: u288 {
            limb0: 0x6e9bb75a3dc91b488b5ef47c,
            limb1: 0xf50d8a8d9d89241f015b9748,
            limb2: 0x170d8b68576c68f7,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa68021d593c46246af22559e,
            limb1: 0x5c2cfc5bc4cd1b48f4704134,
            limb2: 0x296066ede1298f8c,
        },
        r0a1: u288 {
            limb0: 0xfe17dd6765eb9b9625eb6a84,
            limb1: 0x4e35dd8e8f6088bb14299f8d,
            limb2: 0x1a380ab2689106e4,
        },
        r1a0: u288 {
            limb0: 0x82bacf337ca09853df42bc59,
            limb1: 0xa15de4ef34a30014c5a2e9ae,
            limb2: 0x243cc0cec53c778b,
        },
        r1a1: u288 {
            limb0: 0xcb2a1bf18e3ba9349b0a8bf2,
            limb1: 0x35134b2505cbb5a4c91f0ac4,
            limb2: 0x25e45206b13f43c4,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8e97b007ffd9891bd0e77650,
            limb1: 0x77671278ac33f17df6b1db88,
            limb2: 0x243daddc47f5d5c2,
        },
        r0a1: u288 {
            limb0: 0x655fe4c8bbe5ee06aaa0054b,
            limb1: 0xf751450b02c93c7ddea95938,
            limb2: 0x21aa988e950d563f,
        },
        r1a0: u288 {
            limb0: 0xb51b3b6b8582de3eb0549518,
            limb1: 0x84a1031766b7e465f5bbf40c,
            limb2: 0xd46c2d5b95e5532,
        },
        r1a1: u288 {
            limb0: 0x50b6ddd8a5eef0067652191e,
            limb1: 0x298832a0bc46ebed8bff6190,
            limb2: 0xb568b4fe8311f93,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd06ee0875d0e0925c2179a95,
            limb1: 0xbf2e7ffbbbc543ada5ed001f,
            limb2: 0x979d7856aa54c5d,
        },
        r0a1: u288 {
            limb0: 0x848f4290694bcdef3d7c30c5,
            limb1: 0xc3f7fe1757fdb9e03c1b3232,
            limb2: 0x301a096fe8da0504,
        },
        r1a0: u288 {
            limb0: 0xd2dc0cac19b96f10f425755,
            limb1: 0xa509e92389a5b0c570ec80fa,
            limb2: 0x2edb54f6dedfd871,
        },
        r1a1: u288 {
            limb0: 0xb7c7d9e4a43f2136441d0ece,
            limb1: 0x5b5fa6da0bdc26c74260cc42,
            limb2: 0xd480b9d9b9764b4,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x572e0efcb32a9c4a39129d79,
            limb1: 0xb2f16fe6559116f38b517a75,
            limb2: 0x285c1136022e28b,
        },
        r0a1: u288 {
            limb0: 0xf6fa46e27cfda90c0af136a,
            limb1: 0x4ddeb2097bf8b2074c02a3f2,
            limb2: 0x11c0e9cb2b6249e9,
        },
        r1a0: u288 {
            limb0: 0xbef7a090251f19280827fe02,
            limb1: 0xeb2e86aa69bc3b1215292cc,
            limb2: 0x226415ce0163120,
        },
        r1a1: u288 {
            limb0: 0xc401d1985e40de90d5987536,
            limb1: 0xcb604654bdbc5fa047714ef6,
            limb2: 0x5109b7490593f88,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xddb4db99db681d35f71a159c,
            limb1: 0xf71a330019414e6fdee75700,
            limb2: 0x14d9838e7d1918bb,
        },
        r0a1: u288 {
            limb0: 0x203c8bac71951a5f2c653710,
            limb1: 0x9fc93f8da38ecc2957313982,
            limb2: 0x7b6d981259cabd9,
        },
        r1a0: u288 {
            limb0: 0xa7297cdb5be0cc45d48ca6af,
            limb1: 0xa07b4b025ebe6c960eddfc56,
            limb2: 0xef2a5c30ef00652,
        },
        r1a1: u288 {
            limb0: 0xb7f05c76d860e9122b36ecd7,
            limb1: 0x407d6522e1f9ce2bcbf80eda,
            limb2: 0x197625a558f32c36,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x5e95fb1ff0d51cf9b98d1d62,
            limb1: 0xef07f9b569028755392abc64,
            limb2: 0x246fc06d10da445e,
        },
        r0a1: u288 {
            limb0: 0x912534d6cf2ce1bf4f51e4c6,
            limb1: 0xd6818eb242b5e7e57140bd05,
            limb2: 0xb2fa1297469acfa,
        },
        r1a0: u288 {
            limb0: 0xbb8dcdebbfe5f856482a0245,
            limb1: 0xf7c39f1b95aa8d38b9b83885,
            limb2: 0x3190fac54abcea,
        },
        r1a1: u288 {
            limb0: 0x2aa0a98e1506e41aed721dda,
            limb1: 0x98822a136db5c8865af25523,
            limb2: 0x2a346ae6415b1320,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb0f04df9dec94801e48a6ff7,
            limb1: 0xdc59d087c627d38334e5b969,
            limb2: 0x3d36e11420be053,
        },
        r0a1: u288 {
            limb0: 0xc80f070001aa1586189e0215,
            limb1: 0xff849fcbbbe7c00c83ab5282,
            limb2: 0x2a2354b2882706a6,
        },
        r1a0: u288 {
            limb0: 0x48cf70c80f08b6c7dc78adb2,
            limb1: 0xc6632efa77b36a4a1551d003,
            limb2: 0xc2d3533ece75879,
        },
        r1a1: u288 {
            limb0: 0x63e82ba26617416a0b76ddaa,
            limb1: 0xdaceb24adda5a049bed29a50,
            limb2: 0x1a82061a3344043b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7c1fa7901e9c73b6a48fa371,
            limb1: 0xea86bb5fc01ef99a5c9c16b2,
            limb2: 0x59ffc78c524f64d,
        },
        r0a1: u288 {
            limb0: 0xc33d7a12c645ba68e74bec17,
            limb1: 0x68724a1eda83e3f8b17795a8,
            limb2: 0xbfb09bea55bb28,
        },
        r1a0: u288 {
            limb0: 0xdf020650a52f75ac733776fe,
            limb1: 0x372dd66dfbd9aada8c8332af,
            limb2: 0xffb2aede2a692b4,
        },
        r1a1: u288 {
            limb0: 0x95153a2fdb69cb7883f897dd,
            limb1: 0xeda8588bd1ced46e266b23cc,
            limb2: 0x1d9b92c60eefaa28,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9152fecf0f523415acc7c7be,
            limb1: 0xd9632cbfccc4ea5d7bf31177,
            limb2: 0x2d7288c5f8c83ab1,
        },
        r0a1: u288 {
            limb0: 0x53144bfe4030f3f9f5efda8,
            limb1: 0xfeec394fbf392b11c66bae27,
            limb2: 0x28840813ab8a200b,
        },
        r1a0: u288 {
            limb0: 0xdec3b11fbc28b305d9996ec7,
            limb1: 0x5b5f8d9d17199e149c9def6e,
            limb2: 0x10c1a149b6751bae,
        },
        r1a1: u288 {
            limb0: 0x665e8eb7e7d376a2d921c889,
            limb1: 0xfdd76d06e46ee1a943b8788d,
            limb2: 0x8bb21d9960e837b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3a67c28a175200e631aa506a,
            limb1: 0x7397303a34968ff17c06e801,
            limb2: 0x1b81e0c63123688b,
        },
        r0a1: u288 {
            limb0: 0x3490cfd4f076c621dac4a12c,
            limb1: 0xec183578c91b90b72e5887b7,
            limb2: 0x179fb354f608da00,
        },
        r1a0: u288 {
            limb0: 0x9322bde2044dde580a78ba33,
            limb1: 0xfc74821b668d3570cad38f8b,
            limb2: 0x8cec54a291f5e57,
        },
        r1a1: u288 {
            limb0: 0xc2818b6a9530ee85d4b2ae49,
            limb1: 0x8d7b651ad167f2a43d7a2d0a,
            limb2: 0x7c9ca9bab0ffc7f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xce234e4bb73115eb8d0b4df9,
            limb1: 0x4f5f32cf4a519fdd67dc3a2c,
            limb2: 0x1ac0c42948289eaf,
        },
        r0a1: u288 {
            limb0: 0xc278be3add6b35028d239db7,
            limb1: 0xf63e6e8396668ee00df3d4d2,
            limb2: 0x135b3df757fd88a8,
        },
        r1a0: u288 {
            limb0: 0x58b8f85202fb680eb420fb56,
            limb1: 0xc4e9ad984ebd886d83db2da5,
            limb2: 0x195081904a6a8634,
        },
        r1a1: u288 {
            limb0: 0x9af79da61a713f64be25229,
            limb1: 0x5de83a78b001e88de7c86af6,
            limb2: 0x57f819c5f37c575,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x492e573e022bea1b6a901b50,
            limb1: 0x395e67a8b0a573755f42e5cf,
            limb2: 0x2a10948025f7f976,
        },
        r0a1: u288 {
            limb0: 0x4df8bfd12a92271ffb2813aa,
            limb1: 0xbeed717944888c4ba7398f06,
            limb2: 0x23dcc8e9e15c4781,
        },
        r1a0: u288 {
            limb0: 0xe52515dfef2e2e3bd2864b55,
            limb1: 0xf2a9f64ea409359546071bc,
            limb2: 0x1024e476881ec316,
        },
        r1a1: u288 {
            limb0: 0xd269f3e8a0767235ae3d6c4a,
            limb1: 0xe42d8e211bc2485e6afcc538,
            limb2: 0xa524ff1ef4ce9b9,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa576408f8300de3a7714e6ae,
            limb1: 0xe1072c9a16f202ecf37fbc34,
            limb2: 0x1b0cb1e2b5871263,
        },
        r0a1: u288 {
            limb0: 0x2128e2314694b663286e231e,
            limb1: 0x54bea71957426f002508f715,
            limb2: 0x36ecc5dbe069dca,
        },
        r1a0: u288 {
            limb0: 0x17c77cd88f9d5870957850ce,
            limb1: 0xb7f4ec2bc270ce30538fe9b8,
            limb2: 0x766279e588592bf,
        },
        r1a1: u288 {
            limb0: 0x1b6caddf18de2f30fa650122,
            limb1: 0x40b77237a29cada253c126c6,
            limb2: 0x74ff1349b1866c8,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x82c8ed42ac578fde73100cf4,
            limb1: 0x3531ef45876febf8af33c850,
            limb2: 0x1b6779fc4ab79f71,
        },
        r0a1: u288 {
            limb0: 0xebdfbd211b7dc397d75b88ea,
            limb1: 0x587064134fd152ab97aa6688,
            limb2: 0x27cc68590472c123,
        },
        r1a0: u288 {
            limb0: 0xd174c9520df21f3bca6a32c3,
            limb1: 0x8489390cc64162e6e09a6853,
            limb2: 0xba1ea4b7fc689d,
        },
        r1a1: u288 {
            limb0: 0x93d3a15cdf24670cb93a2a0,
            limb1: 0xa98495b7636c88032f96d30,
            limb2: 0x222ef0e0496992bf,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3603266e05560becab36faef,
            limb1: 0x8c3b88c9390278873dd4b048,
            limb2: 0x24a715a5d9880f38,
        },
        r0a1: u288 {
            limb0: 0xe9f595b111cfd00d1dd28891,
            limb1: 0x75c6a392ab4a627f642303e1,
            limb2: 0x17b34a30def82ab6,
        },
        r1a0: u288 {
            limb0: 0xe706de8f35ac8372669fc8d3,
            limb1: 0x16cc7f4032b3f3ebcecd997d,
            limb2: 0x166eba592eb1fc78,
        },
        r1a1: u288 {
            limb0: 0x7d584f102b8e64dcbbd1be9,
            limb1: 0x2ead4092f009a9c0577f7d3,
            limb2: 0x2fe2c31ee6b1d41e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x72253d939632f8c28fb5763,
            limb1: 0x9b943ab13cad451aed1b08a2,
            limb2: 0xdb9b2068e450f10,
        },
        r0a1: u288 {
            limb0: 0x80f025dcbce32f6449fa7719,
            limb1: 0x8a0791d4d1ed60b86e4fe813,
            limb2: 0x1b1bd5dbce0ea966,
        },
        r1a0: u288 {
            limb0: 0xaa72a31de7d815ae717165d4,
            limb1: 0x501c29c7b6aebc4a1b44407f,
            limb2: 0x464aa89f8631b3a,
        },
        r1a1: u288 {
            limb0: 0x6b8d137e1ea43cd4b1f616b1,
            limb1: 0xdd526a510cc84f150cc4d55a,
            limb2: 0x1da2ed980ebd3f29,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x70fb76a6f86ec2ae57f3fdc0,
            limb1: 0x717016e0bc526cb9c090e310,
            limb2: 0x1e4d15fab6023b81,
        },
        r0a1: u288 {
            limb0: 0xa5508536de4b7a9375fb61b5,
            limb1: 0xfa4ee4c48c2227b1f293b853,
            limb2: 0x1ba536c510226965,
        },
        r1a0: u288 {
            limb0: 0xb79d02552f5a964709fa9193,
            limb1: 0xb3c0c59e6ad59485afc448ff,
            limb2: 0x955c73b495ad135,
        },
        r1a1: u288 {
            limb0: 0x9f506850a830fb42227ebeca,
            limb1: 0xa79a4d8b0e4e2b5537b08a14,
            limb2: 0x4cd82039368b5b8,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7da5d4dda6612000738a9dfe,
            limb1: 0x5f9cd6d7d4078a6a55763ed7,
            limb2: 0xf71ee2ba0aa8cb8,
        },
        r0a1: u288 {
            limb0: 0x332022ec83f362ada732cc42,
            limb1: 0xb5fa7f344750972c5d671db7,
            limb2: 0x1e703de6e3dbe3e4,
        },
        r1a0: u288 {
            limb0: 0xb463da6acd4b6b16b0b7d006,
            limb1: 0xf7be522275f1e0a481522bf5,
            limb2: 0x10e1a7e6bd138d97,
        },
        r1a1: u288 {
            limb0: 0x7b36f3503bff91aafd08a222,
            limb1: 0x800142ab877c74e178bd3d88,
            limb2: 0x1c8d1a8ea4a883bc,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x867cced8a010850958f41ff5,
            limb1: 0x6a37fdb2b8993eed18bafe8e,
            limb2: 0x21b9f782109e5a7,
        },
        r0a1: u288 {
            limb0: 0x7307477d650618e66de38d0f,
            limb1: 0xacb622ce92a7e393dbe10ba1,
            limb2: 0x236e70838cee0ed5,
        },
        r1a0: u288 {
            limb0: 0xb564a308aaf5dda0f4af0f0d,
            limb1: 0x55fc71e2f13d8cb12bd51e74,
            limb2: 0x294cf115a234a9e9,
        },
        r1a1: u288 {
            limb0: 0xbd166057df55c135b87f35f3,
            limb1: 0xf9f29b6c50f1cce9b85ec9b,
            limb2: 0x2e8448d167f20f96,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8c6b5ddf609e175a617893fb,
            limb1: 0xd5345899ba52bd9162aed7ea,
            limb2: 0x2aab2170f755b682,
        },
        r0a1: u288 {
            limb0: 0x7327843d2661cb29b55bb248,
            limb1: 0x4f0a4baa747ffe9cc9278c0d,
            limb2: 0x111422f2e799de9f,
        },
        r1a0: u288 {
            limb0: 0xba44aeaaebc3a9f3e2193483,
            limb1: 0xbb2b222487717ff2b4941251,
            limb2: 0x761b2d7917297cf,
        },
        r1a1: u288 {
            limb0: 0x492a6e665e1434696318da85,
            limb1: 0x25bd02e9d5eaa6a0f1a709a3,
            limb2: 0x136896e8fecb2bf4,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xdedaff3205bb953b2c390b8a,
            limb1: 0xe1a899da21c1dafb485c707e,
            limb2: 0x1ec897e7a041493e,
        },
        r0a1: u288 {
            limb0: 0xf52c3c30cd4d3202b34089e0,
            limb1: 0xc652aa1ff533e1aad7532305,
            limb2: 0x2a1df766e5e3aa2e,
        },
        r1a0: u288 {
            limb0: 0x7ac695d3e19d79b234daaf3d,
            limb1: 0x5ce2f92666aec92a650feee1,
            limb2: 0x21ab4fe20d978e77,
        },
        r1a1: u288 {
            limb0: 0xa64a913a29a1aed4e0798664,
            limb1: 0x66bc208b511503d127ff5ede,
            limb2: 0x2389ba056de56a8d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbbd439feeb703e6e73171b99,
            limb1: 0x44960fe0b69823f6eea75465,
            limb2: 0x220271abf96b8160,
        },
        r0a1: u288 {
            limb0: 0xf3f40ff54a9cf881332a9f41,
            limb1: 0xc8b4a2bd6fa81a216e490879,
            limb2: 0x1884a13abbdeee80,
        },
        r1a0: u288 {
            limb0: 0x7ff4b529f932c732d7563212,
            limb1: 0xb2e7f58ee2a9d8c1ef1b5267,
            limb2: 0x159d86ba8510c5c0,
        },
        r1a1: u288 {
            limb0: 0x19968a404d7a7e967113dac,
            limb1: 0xf9af582d73e9389a5067e615,
            limb2: 0x2ca3b1b489bf52b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd88b16e68600a12e6c1f6006,
            limb1: 0x333243b43d3b7ff18d0cc671,
            limb2: 0x2b84b2a9b0f03ed8,
        },
        r0a1: u288 {
            limb0: 0xf3e2b57ddaac822c4da09991,
            limb1: 0xd7c894b3fe515296bb054d2f,
            limb2: 0x10a75e4c6dddb441,
        },
        r1a0: u288 {
            limb0: 0x73c65fbbb06a7b21b865ac56,
            limb1: 0x21f4ecd1403bb78729c7e99b,
            limb2: 0xaf88a160a6b35d4,
        },
        r1a1: u288 {
            limb0: 0xade61ce10b8492d659ff68d0,
            limb1: 0x1476e76cf3a8e0df086ad9eb,
            limb2: 0x2e28cfc65d61e946,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xdf8b54b244108008e7f93350,
            limb1: 0x2ae9a68b9d6b96f392decd6b,
            limb2: 0x160b19eed152271c,
        },
        r0a1: u288 {
            limb0: 0xc18a8994cfbb2e8df446e449,
            limb1: 0x408d51e7e4adedd8f4f94d06,
            limb2: 0x27661b404fe90162,
        },
        r1a0: u288 {
            limb0: 0x1390b2a3b27f43f7ac73832c,
            limb1: 0x14d57301f6002fd328f2d64d,
            limb2: 0x17f3fa337367dddc,
        },
        r1a1: u288 {
            limb0: 0x79cab8ff5bf2f762c5372f80,
            limb1: 0xc979d6f385fae4b5e4785acf,
            limb2: 0x60c5307a735b00f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7034500160fc2d0c08c2321a,
            limb1: 0xbcc3cc6478092a82dec974dc,
            limb2: 0x133f08868ba0325f,
        },
        r0a1: u288 {
            limb0: 0xe0b46cc951f2c670032f316c,
            limb1: 0xf60c5bf2c4cb7a85345a7cb6,
            limb2: 0x25b9b7194cb6272f,
        },
        r1a0: u288 {
            limb0: 0x8131c562c9087ca9234cbd12,
            limb1: 0x2465a7bcd4877e6fdcd9434d,
            limb2: 0x156f15da41d81d97,
        },
        r1a1: u288 {
            limb0: 0xb7e8b53bb4432c93e0b6e402,
            limb1: 0x92d1ed8a9f614d655988eae9,
            limb2: 0x2e64ae5e3cc10be0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xfa92d36dac71ecc401e1fcc7,
            limb1: 0xb4d0f1d6b1967313b7f895f1,
            limb2: 0x290fd7270da94ec,
        },
        r0a1: u288 {
            limb0: 0x8b931fb1b9069ecb6f458203,
            limb1: 0x1e294937d2a0b1275307ed66,
            limb2: 0x2cee82de58bafaa4,
        },
        r1a0: u288 {
            limb0: 0xf51c45a584c71d746da78dd,
            limb1: 0xd7c7b1f8318a489e419e987c,
            limb2: 0x8e5e2c727eb76d9,
        },
        r1a1: u288 {
            limb0: 0xcc0f09673769cca9da33ddc2,
            limb1: 0xda5bff1e1c9b623ee2aac268,
            limb2: 0x21603ad97cde6f8c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x386d7b23c6dccb87637018c9,
            limb1: 0xfed2ea478e9a2210289079e2,
            limb2: 0x100aa83cb843353e,
        },
        r0a1: u288 {
            limb0: 0x229c5c285f049d04c3dc5ce7,
            limb1: 0x28110670fe1d38c53ffcc6f7,
            limb2: 0x1778918279578f50,
        },
        r1a0: u288 {
            limb0: 0xe9ad2c7b8a17a1f1627ff09d,
            limb1: 0xedff5563c3c3e7d2dcc402ec,
            limb2: 0xa8bd6770b6d5aa8,
        },
        r1a1: u288 {
            limb0: 0x66c5c1aeed5c04470b4e8a3d,
            limb1: 0x846e73d11f2d18fe7e1e1aa2,
            limb2: 0x10a60eabe0ec3d78,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe762e1c0b049aa311d2965a4,
            limb1: 0x6860efa1bed6b0535e69a1c6,
            limb2: 0x12ed404b0fc3f572,
        },
        r0a1: u288 {
            limb0: 0x6e6453997acdce1bff99f813,
            limb1: 0x19e61b4d2f649b74d01ecf63,
            limb2: 0x23da648af4da8df0,
        },
        r1a0: u288 {
            limb0: 0x1df2a8347dd56fffa254121b,
            limb1: 0x139e3bccd8d9b6ac6f27a126,
            limb2: 0x1c2cd9950f1d2254,
        },
        r1a1: u288 {
            limb0: 0xb030555a2f83b6bb4bfffe82,
            limb1: 0x3ad4b166976948271f364a3c,
            limb2: 0x2c33ec3c582c2b13,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x88ca191d85be1f6c205257ef,
            limb1: 0xd0cecf5c5f80926c77fd4870,
            limb2: 0x16ec42b5cae83200,
        },
        r0a1: u288 {
            limb0: 0x154cba82460752b94916186d,
            limb1: 0x564f6bebac05a4f3fb1353ac,
            limb2: 0x2d47a47da836d1a7,
        },
        r1a0: u288 {
            limb0: 0xb39c4d6150bd64b4674f42ba,
            limb1: 0x93c967a38fe86f0779bf4163,
            limb2: 0x1a51995a49d50f26,
        },
        r1a1: u288 {
            limb0: 0xeb7bdec4b7e304bbb0450608,
            limb1: 0x11fc9a124b8c74b3d5560ea4,
            limb2: 0xbfa9bd7f55ad8ac,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x48fe7e313f87fef2824d1c9d,
            limb1: 0xa5806edac7d9b981701b9e13,
            limb2: 0x2369c0b00959983,
        },
        r0a1: u288 {
            limb0: 0x9b36709c9670a8f5ceea6a5f,
            limb1: 0x26417d1dba49e8cf713f2a42,
            limb2: 0x1e2a195cc83bfb94,
        },
        r1a0: u288 {
            limb0: 0xfeb1a8ce61223c7f985975bb,
            limb1: 0xcfd5386189b9bc1555bd0f42,
            limb2: 0x2e60ba94facb7a58,
        },
        r1a1: u288 {
            limb0: 0x47968597b96cd2b35ab15e80,
            limb1: 0x767b381a42ee6802487f812a,
            limb2: 0x1c86a0a1fa308c6,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2fdc574c85cf0c0ce5e07a51,
            limb1: 0xd2439bf7b00bddc4cfb01b0c,
            limb2: 0x125c3bbdeb0bd2da,
        },
        r0a1: u288 {
            limb0: 0x9d664714bae53cafcb5ef55d,
            limb1: 0x495c01724790853548f5e4de,
            limb2: 0x2ce5e2e263725941,
        },
        r1a0: u288 {
            limb0: 0x98071eb7fe88c9124aee3774,
            limb1: 0xc3f66947a52bd2f6d520579f,
            limb2: 0x2eaf775dbd52f7d3,
        },
        r1a1: u288 {
            limb0: 0x23e5594948e21db2061dca92,
            limb1: 0xd0ffa6f6c77290531c185431,
            limb2: 0x604c085de03afb1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x523ad72cba331ac54b065e6a,
            limb1: 0xcb99732bb9de01c6189d0434,
            limb2: 0x40379f2d6aa7e5c,
        },
        r0a1: u288 {
            limb0: 0xacfeab583e9143a0bef25b3c,
            limb1: 0xc78089f933930c74e6f79ccd,
            limb2: 0x1e9d312c6652122c,
        },
        r1a0: u288 {
            limb0: 0xf6ee63d3985d514038747371,
            limb1: 0xc7527f863c0282e4b6f4232b,
            limb2: 0x2a3ab17d629c9848,
        },
        r1a1: u288 {
            limb0: 0x74a0b7e0d7d761fce2c9bfef,
            limb1: 0xf100a9481c113c9efe7e2f79,
            limb2: 0x273d0203fbb1bf8e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xeec2912e15f6bda39d4e005e,
            limb1: 0x2b8610c44d27bdbc6ba2aac5,
            limb2: 0x78ddc4573fc1fed,
        },
        r0a1: u288 {
            limb0: 0x48099a0da11ea21de015229d,
            limb1: 0x5fe937100967d5cc544f4af1,
            limb2: 0x2c9ffe6d7d7e9631,
        },
        r1a0: u288 {
            limb0: 0xa70d251296ef1ae37ceb7d03,
            limb1: 0x2adadcb7d219bb1580e6e9c,
            limb2: 0x180481a57f22fd03,
        },
        r1a1: u288 {
            limb0: 0xacf46db9631037dd933eb72a,
            limb1: 0x8a58491815c7656292a77d29,
            limb2: 0x261e3516c348ae12,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x907e8bacb57fbcc7ce1230a7,
            limb1: 0xd4ca37ac9464ad4730f5fd34,
            limb2: 0x111c31efaddc45d9,
        },
        r0a1: u288 {
            limb0: 0x8d2b1598511644d487a42cfa,
            limb1: 0xbb31a722193c0515c960ef31,
            limb2: 0x3111033f68802ce,
        },
        r1a0: u288 {
            limb0: 0x13e66ed8e12eb4fdf5319c7b,
            limb1: 0x351222b71b2f48a4dfc08479,
            limb2: 0x1057c58d3454bfae,
        },
        r1a1: u288 {
            limb0: 0xf86c6d1198ea4012d916ec80,
            limb1: 0x8964fa7a9b04216e21f51976,
            limb2: 0xcc5433789234bc5,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2bfa32f0a09c3e2cfb8f6a38,
            limb1: 0x7a24df3ff3c7119a59d49318,
            limb2: 0x10e42281d64907ba,
        },
        r0a1: u288 {
            limb0: 0xce42177a66cdeb4207d11e0c,
            limb1: 0x3322aa425a9ca270152372ad,
            limb2: 0x2f7fa83db407600c,
        },
        r1a0: u288 {
            limb0: 0x62a8ff94fd1c7b9035af4446,
            limb1: 0x3ad500601bbb6e7ed1301377,
            limb2: 0x254d253ca06928f,
        },
        r1a1: u288 {
            limb0: 0xf8f1787cd8e730c904b4386d,
            limb1: 0x7fd3744349918d62c42d24cc,
            limb2: 0x28a05e105d652eb8,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6ef31e059d602897fa8e80a8,
            limb1: 0x66a0710847b6609ceda5140,
            limb2: 0x228c0e568f1eb9c0,
        },
        r0a1: u288 {
            limb0: 0x7b47b1b133c1297b45cdd79b,
            limb1: 0x6b4f04ed71b58dafd06b527b,
            limb2: 0x13ae6db5254df01a,
        },
        r1a0: u288 {
            limb0: 0xbeca2fccf7d0754dcf23ddda,
            limb1: 0xe3d0bcd7d9496d1e5afb0a59,
            limb2: 0x305a0afb142cf442,
        },
        r1a1: u288 {
            limb0: 0x2d299847431477c899560ecf,
            limb1: 0xbcd9e6c30bedee116b043d8d,
            limb2: 0x79473a2a7438353,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x88c7d4d3e8af8585833bc849,
            limb1: 0x3b43a6e1bca5330d0bf9c960,
            limb2: 0x1f8c6e9e0d8491fb,
        },
        r0a1: u288 {
            limb0: 0x815e98e4aa6dc4a30a103239,
            limb1: 0x263c5c03fe84e6fa1fd1f7c5,
            limb2: 0x28a0977bccbf48f4,
        },
        r1a0: u288 {
            limb0: 0xfaf9d80b8ce980549c614824,
            limb1: 0x8425a91432cf58678edaff04,
            limb2: 0x90c49f66f1bee52,
        },
        r1a1: u288 {
            limb0: 0x610a43f4919815370134cf17,
            limb1: 0xd1b617016dabc1eb88fbf445,
            limb2: 0xe3928b95c2e4805,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb69cebca61842cbf1c42c47e,
            limb1: 0xc0696e5ace4eb08e4b98e097,
            limb2: 0x1a3f7a76cb05bbda,
        },
        r0a1: u288 {
            limb0: 0xa333127a5d091d0297b789c5,
            limb1: 0x9d547cfc83543dd3d6d76aaf,
            limb2: 0x2f488ca11ab34b7f,
        },
        r1a0: u288 {
            limb0: 0xe5f90b56a3e9cf0d41429d86,
            limb1: 0x320dac2f0876d5d2fc5b66fe,
            limb2: 0x850c6edd5fb7d07,
        },
        r1a1: u288 {
            limb0: 0x30b2e0b4a73cb407f69ae242,
            limb1: 0x93b60f4ee3468627457a631f,
            limb2: 0x98c794b9b4c3892,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x65b71fe695e7ccd4b460dace,
            limb1: 0xa6ceba62ef334e6fe91301d5,
            limb2: 0x299f578d0f3554e6,
        },
        r0a1: u288 {
            limb0: 0xaf781dd030a274e7ecf0cfa4,
            limb1: 0x2095020d373a14d7967797aa,
            limb2: 0x6a7f9df6f185bf8,
        },
        r1a0: u288 {
            limb0: 0x8e91e2dba67d130a0b274df3,
            limb1: 0xe192a19fce285c12c6770089,
            limb2: 0x6e9acf4205c2e22,
        },
        r1a1: u288 {
            limb0: 0xbcd5c206b5f9c77d667189bf,
            limb1: 0x656a7e2ebc78255d5242ca9,
            limb2: 0x25f43fec41d2b245,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x88379739e2fa906d22368354,
            limb1: 0x7b87f1e2eb62c93b614ab9f5,
            limb2: 0x2814eae3462cd1b9,
        },
        r0a1: u288 {
            limb0: 0x863d3a6a2708a92ff1e7f66a,
            limb1: 0xfff1b8aa4f545e228699bf5d,
            limb2: 0x14d16f9b6be1e633,
        },
        r1a0: u288 {
            limb0: 0xf58e18a465eb821da11a1e8b,
            limb1: 0x7c420c158041c944373fce20,
            limb2: 0xb7c0ae4ba345834,
        },
        r1a1: u288 {
            limb0: 0xea8d3ea11f17923f7c4c2427,
            limb1: 0x9984664cfaf4242f5a4a764c,
            limb2: 0x29d9defcf2d047ab,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x4e56e6733cce20d9c5b16d96,
            limb1: 0xc7ef260535fb75b9d3e089f,
            limb2: 0x292dd4aa636e7729,
        },
        r0a1: u288 {
            limb0: 0x6e7e1038b336f36519c9faaf,
            limb1: 0x3c66bd609510309485e225c7,
            limb2: 0x10cacac137411eb,
        },
        r1a0: u288 {
            limb0: 0x4a3e8b96278ac092fe4f3b15,
            limb1: 0xba47e583e2750b42f93c9631,
            limb2: 0x125da6bd69495bb9,
        },
        r1a1: u288 {
            limb0: 0xae7a56ab4b959a5f6060d529,
            limb1: 0xc3c263bfd58c0030c063a48e,
            limb2: 0x2f4d15f13fae788c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x301e0885c84d273b6d323124,
            limb1: 0x11fd5c75e269f7a30fa4154f,
            limb2: 0x19afdcfdcce2fc0d,
        },
        r0a1: u288 {
            limb0: 0x3d13519f934526be815c38b0,
            limb1: 0xd43735909547da73838874fc,
            limb2: 0x255d8aca30f4e0f6,
        },
        r1a0: u288 {
            limb0: 0x90a505b76f25a3396e2cea79,
            limb1: 0x3957a2d0848c54b9079fc114,
            limb2: 0x1ba0cd3a9fe6d4bb,
        },
        r1a1: u288 {
            limb0: 0xc47930fba77a46ebb1db30a9,
            limb1: 0x993a1cb166e9d40bebab02b2,
            limb2: 0x1deb16166d48118b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x517d1d15b22097725e84eb7e,
            limb1: 0xb5b2cee352a8420e3cf5f1d2,
            limb2: 0x2b86336547a004f5,
        },
        r0a1: u288 {
            limb0: 0xb376353527f20bff3d12925b,
            limb1: 0x45d3b2637b4ee55e2a193618,
            limb2: 0x1a30368c0d783c9e,
        },
        r1a0: u288 {
            limb0: 0xe5262dc9af209fe29d0638b8,
            limb1: 0x1c90fb4a1e5a487f9faa83f5,
            limb2: 0x5e39d7b78053042,
        },
        r1a1: u288 {
            limb0: 0xc0bac608a7bf916b4b965fc3,
            limb1: 0x6eec7d04bff3f9b0a8369f36,
            limb2: 0x2bfaf0ee662b758f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc75d0cb34a024a7a83cfafaf,
            limb1: 0x601df20d591aec71b03e7259,
            limb2: 0x7af1f16d5d7f0ca,
        },
        r0a1: u288 {
            limb0: 0x2c72556ba8e832c8ce83bf69,
            limb1: 0x71a590411d4e53a0aa54ea7f,
            limb2: 0xe96897b1b3e64c6,
        },
        r1a0: u288 {
            limb0: 0xc76ba644f31b31035e204bd8,
            limb1: 0xdd5b3191941ca60cdde51a12,
            limb2: 0x22f3e2d350366f9b,
        },
        r1a1: u288 {
            limb0: 0xd0e37280b607f615d8ffe945,
            limb1: 0x9d2a51c861dbd10421478252,
            limb2: 0x3e440b56077c4e8,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb15bbaec50ff49d30e49f74a,
            limb1: 0xc90a8c79fb045c5468f14151,
            limb2: 0x25e47927e92df0e3,
        },
        r0a1: u288 {
            limb0: 0x57f66909d5d40dfb8c7b4d5c,
            limb1: 0xea5265282e2139c48c1953f2,
            limb2: 0x2d7f5e6aff2381f6,
        },
        r1a0: u288 {
            limb0: 0x2a2f573b189a3c8832231394,
            limb1: 0x738abc15844895ffd4733587,
            limb2: 0x20aa11739c4b9bb4,
        },
        r1a1: u288 {
            limb0: 0x51695ec614f1ff4cce2f65d1,
            limb1: 0x6765aae6cb895a2406a6dd7e,
            limb2: 0x1126ee431c522da0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3d9f7e50f11bd816309fb4e3,
            limb1: 0x2c33939b996510e000f8d109,
            limb2: 0xcf139c833129e2a,
        },
        r0a1: u288 {
            limb0: 0x837d0b1c201528df26e7e974,
            limb1: 0x868d3fc7962b28311d3677ea,
            limb2: 0x11bc95e9c545e5af,
        },
        r1a0: u288 {
            limb0: 0xc128a0e0893601381df47d21,
            limb1: 0xa06e209f1e605439dae21c09,
            limb2: 0x30062ebb70e6bb60,
        },
        r1a1: u288 {
            limb0: 0x23de111c087570e4d550bb82,
            limb1: 0xdb93eb260dc6f6a9c68a997e,
            limb2: 0x1e812c7090c9a348,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9214fc3209f1518b05fd21c6,
            limb1: 0x9bc8ce4f56423009710770e8,
            limb2: 0x32445cc6972799c,
        },
        r0a1: u288 {
            limb0: 0x93ef401ecd9cfae3644d22e6,
            limb1: 0xce5a741a9847a144cfaf8c96,
            limb2: 0xf7a814d5726da4a,
        },
        r1a0: u288 {
            limb0: 0xd19264d986f163b133a91c0c,
            limb1: 0x529dc5ce4b193c0f672c6a32,
            limb2: 0x2e9a118959353374,
        },
        r1a1: u288 {
            limb0: 0x3d97d6e8f45072cc9e85e412,
            limb1: 0x4dafecb04c3bb23c374f0486,
            limb2: 0xa174dd4ac8ee628,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9d9a35e6646ebbe3bae31282,
            limb1: 0xdeb55ace850c1c599d7bdd53,
            limb2: 0x533acfaf80f6906,
        },
        r0a1: u288 {
            limb0: 0xcb28560037d716a8cdb95581,
            limb1: 0xe9b61352822090dfe7ccf4e7,
            limb2: 0x14d86b95430af714,
        },
        r1a0: u288 {
            limb0: 0xbb70cf382532ed2256610998,
            limb1: 0xeadd0c50e258aceefeb0ac56,
            limb2: 0x27a03830e9634f66,
        },
        r1a1: u288 {
            limb0: 0xcde850c151a59618556b72bf,
            limb1: 0x7e6cd02f1784873610744f5a,
            limb2: 0x25af83a1e3c6b692,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x98d8b0c4adcf27bceb305c2c,
            limb1: 0x859afa9c7668ed6152d8cba3,
            limb2: 0x29e7694f46e3a272,
        },
        r0a1: u288 {
            limb0: 0x1d970845365594307ba97556,
            limb1: 0xd002d93ad793e154afe5b49b,
            limb2: 0x12ca77d3fb8eee63,
        },
        r1a0: u288 {
            limb0: 0x9f2934faefb8268e20d0e337,
            limb1: 0xbc4b5e1ec056881319f08766,
            limb2: 0x2e103461759a9ee4,
        },
        r1a1: u288 {
            limb0: 0x7adc6cb87d6b43000e2466b6,
            limb1: 0x65e5cefa42b25a7ee8925fa6,
            limb2: 0x2560115898d7362a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9440b1cd94ed9cfd1f3ad443,
            limb1: 0xfabf18e2dfac8fd29d3350d4,
            limb2: 0x2609c458048ea6b7,
        },
        r0a1: u288 {
            limb0: 0xa2438c10e713d11a68088351,
            limb1: 0x12552584a37cfffef8464c36,
            limb2: 0x1c5aa8de22d9188a,
        },
        r1a0: u288 {
            limb0: 0xad9ac66c29ee2b9a03871bc1,
            limb1: 0x57588423f64eff30fa687f74,
            limb2: 0x298a8db700c49bf6,
        },
        r1a1: u288 {
            limb0: 0x12a8526c7783ec30abb7482a,
            limb1: 0x6307aabef766980d2a0ad8e8,
            limb2: 0xf4078c1d7d60b88,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x64d864643668392c0e357cc4,
            limb1: 0x4c9bf66853f1b287015ab84c,
            limb2: 0x2f5f1b92ad7ee4d4,
        },
        r0a1: u288 {
            limb0: 0xdc33c8da5c575eef6987a0e1,
            limb1: 0x51cc07c7ef28e1b8d934bc32,
            limb2: 0x2358d94a17ec2a44,
        },
        r1a0: u288 {
            limb0: 0xf659845b829bbba363a2497b,
            limb1: 0x440f348e4e7bed1fb1eb47b2,
            limb2: 0x1ad0eaab0fb0bdab,
        },
        r1a1: u288 {
            limb0: 0x1944bb6901a1af6ea9afa6fc,
            limb1: 0x132319df135dedddf5baae67,
            limb2: 0x52598294643a4aa,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x76fd94c5e6f17fa6741bd7de,
            limb1: 0xc2e0831024f67d21013e0bdd,
            limb2: 0x21e2af6a43119665,
        },
        r0a1: u288 {
            limb0: 0xad290eab38c64c0d8b13879b,
            limb1: 0xdd67f881be32b09d9a6c76a0,
            limb2: 0x8000712ce0392f2,
        },
        r1a0: u288 {
            limb0: 0xd30a46f4ba2dee3c7ace0a37,
            limb1: 0x3914314f4ec56ff61e2c29e,
            limb2: 0x22ae1ba6cd84d822,
        },
        r1a1: u288 {
            limb0: 0x5d888a78f6dfce9e7544f142,
            limb1: 0x9439156de974d3fb6d6bda6e,
            limb2: 0x106c8f9a27d41a4f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x21ed963660e500b4426731e7,
            limb1: 0x21a786cd572c013ff5cb5050,
            limb2: 0x16aebc7f83fb1b32,
        },
        r0a1: u288 {
            limb0: 0xc37d3a1841bd02d0d1e87532,
            limb1: 0xd716ac423262d5f5fe992cf9,
            limb2: 0x241b4d1936824659,
        },
        r1a0: u288 {
            limb0: 0x9465d0f9eb7fb34e1062fc6e,
            limb1: 0xddbafd2abce945ef02de812f,
            limb2: 0x2bc9b9b989f4d2a1,
        },
        r1a1: u288 {
            limb0: 0xc52b951432ef220554b68f5a,
            limb1: 0x129148db9f08eae2f91f5d6e,
            limb2: 0x2c1c6ba91edecee7,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x49889d3b89e8792e064aa0e5,
            limb1: 0xfe9d38b1ae39bc3d51e98fc3,
            limb2: 0x21aa6e701d522aab,
        },
        r0a1: u288 {
            limb0: 0x1e02105c56c271343fb78d27,
            limb1: 0x8fb36b190a61aa02a4e2d7ad,
            limb2: 0x7b140e9bbde39a,
        },
        r1a0: u288 {
            limb0: 0xe198a096c41c5ccba62b13c2,
            limb1: 0xa3cf04c77255a64bb5f37968,
            limb2: 0x8fc8fdc4505f2c2,
        },
        r1a1: u288 {
            limb0: 0x8437bbd336facdaf6ade4a66,
            limb1: 0xc0e3db98e916f3706aaf6c79,
            limb2: 0x1caebcc5a103a74c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x92c09e4796207b802168341b,
            limb1: 0xd2d9d6acffd7829066cc49ce,
            limb2: 0xc89c2d0a7b2c81e,
        },
        r0a1: u288 {
            limb0: 0x47e3c1cf6cdb6f3efe778c7f,
            limb1: 0x66b347099b6436794cf062eb,
            limb2: 0x18b4ccc64ae0a857,
        },
        r1a0: u288 {
            limb0: 0x7d5793606a73b2740c71484a,
            limb1: 0xa0070135ca2dc571b28e3c9c,
            limb2: 0x1bc03576e04b94cf,
        },
        r1a1: u288 {
            limb0: 0x1ba85b29875e638c10f16c99,
            limb1: 0x158f2f2acc3c2300bb9f9225,
            limb2: 0x42d8a8c36ea97c6,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xefa9ecb2a75cb4c891b79131,
            limb1: 0x803015a9992e6d4a36e68c18,
            limb2: 0x2b9eedc0c7071a23,
        },
        r0a1: u288 {
            limb0: 0x15ea48bc698f46f09770471a,
            limb1: 0xf3f94bbb6b72941228327534,
            limb2: 0x1d8de83321441b1f,
        },
        r1a0: u288 {
            limb0: 0xbd8dc758b933ac0b49c08443,
            limb1: 0xef24ccca52c83d44a01966f9,
            limb2: 0x59312e4e437de43,
        },
        r1a1: u288 {
            limb0: 0x265125860b72e000a7d58c27,
            limb1: 0xe9f754fc522d36b0b6701f9b,
            limb2: 0x74b9321a2be7796,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9440ad13408319cecb07087b,
            limb1: 0x537afc0c0cfe8ff761c24e08,
            limb2: 0x48e4ac10081048d,
        },
        r0a1: u288 {
            limb0: 0xa37fb82b03a2c0bb2aa50c4f,
            limb1: 0xd3797f05c8fb84f6b630dfb,
            limb2: 0x2dffde2d6c7e43ff,
        },
        r1a0: u288 {
            limb0: 0xc55d2eb1ea953275e780e65b,
            limb1: 0xe141cf680cab57483c02e4c7,
            limb2: 0x1b71395ce5ce20ae,
        },
        r1a1: u288 {
            limb0: 0xe4fab521f1212a1d301065de,
            limb1: 0x4f8d31c78df3dbe4ab721ef2,
            limb2: 0x2828f21554706a0e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8cefc2f2af2a3082b790784e,
            limb1: 0x97ac13b37c6fbfc736a3d456,
            limb2: 0x683b1cdffd60acd,
        },
        r0a1: u288 {
            limb0: 0xa266a8188a8c933dcffe2d02,
            limb1: 0x18d3934c1838d7bce81b2eeb,
            limb2: 0x206ac5cdda42377,
        },
        r1a0: u288 {
            limb0: 0x90332652437f6e177dc3b28c,
            limb1: 0x75bd8199433d607735414ee8,
            limb2: 0x29d6842d8298cf7e,
        },
        r1a1: u288 {
            limb0: 0xadedf46d8ea11932db0018e1,
            limb1: 0xbc7239ae9d1453258037befb,
            limb2: 0x22e7ebdd72c6f7a1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9a86929acd68fa8f8233b580,
            limb1: 0x414b353a483c539455c5548,
            limb2: 0x2de50076d886dcfe,
        },
        r0a1: u288 {
            limb0: 0xca2d03bb470bf2be7dba676d,
            limb1: 0xbe3934863a0f215f990b2317,
            limb2: 0x2531a345a7fbc110,
        },
        r1a0: u288 {
            limb0: 0xb8ad8cffa52d7412851cdac3,
            limb1: 0x3602c959b5a3f0a2b3e0f1ad,
            limb2: 0x22c442560ef48d88,
        },
        r1a1: u288 {
            limb0: 0x2fc8f00f797d3a029d8dacda,
            limb1: 0x710cea4ce8bf5795b5b5a3d3,
            limb2: 0x20f0f2293a454e9a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbb30a005a96ab4abfec38ebc,
            limb1: 0x418620eaf9b40a9fbceab376,
            limb2: 0x39b2ccdac7ee2ff,
        },
        r0a1: u288 {
            limb0: 0xed964a2c0e242a0ef9e53e60,
            limb1: 0xd070d01273df97044f0a1c68,
            limb2: 0x7538b2cf3ff2710,
        },
        r1a0: u288 {
            limb0: 0xa7ecf736b9609fb36596b1d8,
            limb1: 0xe7e19cea602913988ff5c011,
            limb2: 0x61aef47ebfdd84d,
        },
        r1a1: u288 {
            limb0: 0x1e178aa3fdc02441a9af6e1e,
            limb1: 0x9478ea6b6c4f5d063b01ff36,
            limb2: 0x1d875e984dddb3dd,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x348e15357d9299e582033136,
            limb1: 0x53578c46b15abb39da35a56e,
            limb2: 0x1043b711f86bb33f,
        },
        r0a1: u288 {
            limb0: 0x9fa230a629b75217f0518e7c,
            limb1: 0x77012a4bb8751322a406024d,
            limb2: 0x121e2d845d972695,
        },
        r1a0: u288 {
            limb0: 0x5600f2d51f21d9dfac35eb10,
            limb1: 0x6fde61f876fb76611fb86c1a,
            limb2: 0x2bf4fbaf5bd0d0df,
        },
        r1a1: u288 {
            limb0: 0xd732aa0b6161aaffdae95324,
            limb1: 0xb3c4f8c3770402d245692464,
            limb2: 0x2a0f1740a293e6f0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xfc5f86441bdbe7e5367fe3a6,
            limb1: 0xebda25ac44530e2119513945,
            limb2: 0x22939a0936d2a7f6,
        },
        r0a1: u288 {
            limb0: 0xa86450a183e47619997b41b5,
            limb1: 0x454c3e0365652ce831fdefa7,
            limb2: 0x55224e74159f3f0,
        },
        r1a0: u288 {
            limb0: 0xaa53efa0e33cb63ed6491bc7,
            limb1: 0xc1cc644fff42214dc1e36907,
            limb2: 0x699dcb8d05cde33,
        },
        r1a1: u288 {
            limb0: 0x5c8b73f079e6043bf8cb4a4a,
            limb1: 0xd0d0d97b69a71d3384eb0131,
            limb2: 0xf7e66b3e154566a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa9e2efa41aaa98ab59728940,
            limb1: 0x163c0425f66ce72daef2f53e,
            limb2: 0x2feaf1b1770aa7d8,
        },
        r0a1: u288 {
            limb0: 0x3bb7afd3c0a79b6ac2c4c063,
            limb1: 0xee5cb42e8b2bc999e312e032,
            limb2: 0x1af2071ae77151c3,
        },
        r1a0: u288 {
            limb0: 0x1cef1c0d8956d7ceb2b162e7,
            limb1: 0x202b4af9e51edfc81a943ded,
            limb2: 0xc9e943ffbdcfdcb,
        },
        r1a1: u288 {
            limb0: 0xe18b1b34798b0a18d5ad43dd,
            limb1: 0x55e8237731941007099af6b8,
            limb2: 0x1472c0290db54042,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xf256725151b44c1104c9236,
            limb1: 0xb073f79e916718a08e2a6454,
            limb2: 0x2e1956d1beb61634,
        },
        r0a1: u288 {
            limb0: 0xf4648151d0ee891579c2a32f,
            limb1: 0xa346aebb4f2f55e2f8e41a7f,
            limb2: 0x1f1f7d23d9f5d899,
        },
        r1a0: u288 {
            limb0: 0x98e4db9aea1ad216244e7e2d,
            limb1: 0xaff6f8886dacb4323b668189,
            limb2: 0x26a837715d51d8b7,
        },
        r1a1: u288 {
            limb0: 0xf0f08cc03915c1fcec052a47,
            limb1: 0xd1f6be65e45e16b3f6559274,
            limb2: 0x18a8da56daed8e10,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb4c7963e0d1dc082de0725e,
            limb1: 0x375a7a3d765918de24804223,
            limb2: 0xf177b77b031596d,
        },
        r0a1: u288 {
            limb0: 0x87a7b9c5f10500b0b40d7a1e,
            limb1: 0x6f234d1dc7f1394b55858810,
            limb2: 0x26288146660a3914,
        },
        r1a0: u288 {
            limb0: 0xa6308c89cebe40447abf4a9a,
            limb1: 0x657f0fdda13b1f8ee314c22,
            limb2: 0x1701aabc250a9cc7,
        },
        r1a1: u288 {
            limb0: 0x9db9bf660dc77cbe2788a755,
            limb1: 0xbdf9c1c15a4bd502a119fb98,
            limb2: 0x14b4de3d26bd66e1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x53c49c62ca96007e14435295,
            limb1: 0x85aeb885e4123ca8d3232fdf,
            limb2: 0x750017ce108abf3,
        },
        r0a1: u288 {
            limb0: 0xba6bf3e25d370182e4821239,
            limb1: 0x39de83bf370bd2ba116e8405,
            limb2: 0x2b8417a72ba6d940,
        },
        r1a0: u288 {
            limb0: 0xa922f50550d349849b14307b,
            limb1: 0x569766b6feca6143a5ddde9d,
            limb2: 0x2c3c6765b25a01d,
        },
        r1a1: u288 {
            limb0: 0x6016011bdc3b506563b0f117,
            limb1: 0xbab4932beab93dde9b5b8a5c,
            limb2: 0x1bf3f698de0ace60,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xce7dd4531fa4fe844a1e9f42,
            limb1: 0xbd7d828ef6200b12c5043543,
            limb2: 0x1908dd4689382a3d,
        },
        r0a1: u288 {
            limb0: 0x5c819c8cd84578a13769b4f3,
            limb1: 0xad7c49731c88ef2fca9faa35,
            limb2: 0x1574a5b030215dad,
        },
        r1a0: u288 {
            limb0: 0x4f612a0638dabb303028a572,
            limb1: 0x6ed2f284bc8f1ed38d323339,
            limb2: 0x1fd8149b11cd8f3a,
        },
        r1a1: u288 {
            limb0: 0x9a5d04af3e3aa92bebb3218d,
            limb1: 0x97e54145b62353539330a283,
            limb2: 0x695bd4c3f9d1a17,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xf72999a3b930e4d6d80e4805,
            limb1: 0xb19e696701ed2e016823ff4b,
            limb2: 0x1a9513643cda440d,
        },
        r0a1: u288 {
            limb0: 0xa7fdacd894397c8aa660567d,
            limb1: 0x95fb116d090be9e37d69651d,
            limb2: 0x1457513ed9312f0f,
        },
        r1a0: u288 {
            limb0: 0x8eaeb772ebfa302f42d84969,
            limb1: 0x3a38c0a0244a28b16896486,
            limb2: 0xf8d0205c117cca5,
        },
        r1a1: u288 {
            limb0: 0xd525bf04dc689391d43f327f,
            limb1: 0xf13aff4755934748c92c6741,
            limb2: 0x19e2c50010672817,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb9f05ffda3ee208f990ff3a8,
            limb1: 0x6201d08440b28ea672b9ea93,
            limb2: 0x1ed60e5a5e778b42,
        },
        r0a1: u288 {
            limb0: 0x8e8468b937854c9c00582d36,
            limb1: 0x7888fa8b2850a0c555adb743,
            limb2: 0xd1342bd01402f29,
        },
        r1a0: u288 {
            limb0: 0xf5c4c66a974d45ec754b3873,
            limb1: 0x34322544ed59f01c835dd28b,
            limb2: 0x10fe4487a871a419,
        },
        r1a1: u288 {
            limb0: 0xedf4af2df7c13d6340069716,
            limb1: 0x8592eea593ece446e8b2c83b,
            limb2: 0x12f9280ce8248724,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3e29757616a8dbc8d241e39,
            limb1: 0xfc31a17b60c5f7b177a91c9b,
            limb2: 0x2637e2e592c05e69,
        },
        r0a1: u288 {
            limb0: 0x8d287e4e033afccfec794cea,
            limb1: 0xd3a1a5b6a9a567344ffadd2f,
            limb2: 0x13436cd2bd1d8a7b,
        },
        r1a0: u288 {
            limb0: 0x4b7b8a253a4b8cbc9e934c78,
            limb1: 0x7d6232ec3328ab7f42abcc9b,
            limb2: 0x7060a014440389b,
        },
        r1a1: u288 {
            limb0: 0x9f02a47ec1685c505b6adc0f,
            limb1: 0xfac823bb726c48939cb0acd,
            limb2: 0x1dbefe2e5ff410c3,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe67f72c6d45f1bb04403139f,
            limb1: 0x9233e2a95d3f3c3ff2f7e5b8,
            limb2: 0x1f931e8e4343b028,
        },
        r0a1: u288 {
            limb0: 0x20ef53907af71803ce3ca5ca,
            limb1: 0xd99b6637ee9c73150b503ea4,
            limb2: 0x1c9759def8a98ea8,
        },
        r1a0: u288 {
            limb0: 0xa0a3b24c9089d224822fad53,
            limb1: 0xdfa2081342a7a895062f3e50,
            limb2: 0x185e8cf6b3e494e6,
        },
        r1a1: u288 {
            limb0: 0x8752a12394b29d0ba799e476,
            limb1: 0x1493421da067a42e7f3d0f8f,
            limb2: 0x67e7fa3e3035edf,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x60e869dd243f2707235b4355,
            limb1: 0x4a184aa6facf9a96c80247e3,
            limb2: 0x1c8a6387c8b58a87,
        },
        r0a1: u288 {
            limb0: 0xa5502bad308a0c4457dc9dd3,
            limb1: 0xe3df458a0880a3b9c05907d2,
            limb2: 0x19764371e4234ecf,
        },
        r1a0: u288 {
            limb0: 0xbc864240f97ea663a186268a,
            limb1: 0xe0d8fe813f7e679596f765ec,
            limb2: 0x1431261ba40966e0,
        },
        r1a1: u288 {
            limb0: 0x238a9c4458f7784f56167fe3,
            limb1: 0x51f50e87f73d3c1f499bc566,
            limb2: 0x1849a8d344d57a90,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6d6138c95464e5e774ae7ba0,
            limb1: 0xe6ca73a5498e4ccd4bb68fc7,
            limb2: 0x15bf8aa8ed1beff6,
        },
        r0a1: u288 {
            limb0: 0xabd7c55a134ed405b4966d3c,
            limb1: 0xe69dd725ccc4f9dd537fe558,
            limb2: 0x2df4a03e2588a8f1,
        },
        r1a0: u288 {
            limb0: 0x7cf42890de0355ffc2480d46,
            limb1: 0xe33c2ad9627bcb4b028c2358,
            limb2: 0x2a18767b40de20bd,
        },
        r1a1: u288 {
            limb0: 0x79737d4a87fab560f3d811c6,
            limb1: 0xa88fee5629b91721f2ccdcf7,
            limb2: 0x2b51c831d3404d5e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x701d6901a9a317ee6b7e71ca,
            limb1: 0xd55f54f56a75feb5db4086be,
            limb2: 0x5c87c163e6bb933,
        },
        r0a1: u288 {
            limb0: 0x4726e722b48285b8278f499d,
            limb1: 0x9c3a71e2ae0f21b7ba1774ed,
            limb2: 0x291362c65099d221,
        },
        r1a0: u288 {
            limb0: 0x7c538a5bd5adcb7b8a555fda,
            limb1: 0xb3e198cd0d45072ea95c4803,
            limb2: 0x63a7f7f17b0c8d3,
        },
        r1a1: u288 {
            limb0: 0x283cc20e456427afd361d330,
            limb1: 0xcace59d704e695a7a4b559c2,
            limb2: 0x1a54763fd8aaa412,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9812f6145cf7e949fa207f20,
            limb1: 0x4061c36b08d5bcd408b14f19,
            limb2: 0x8332e08b2eb51ed,
        },
        r0a1: u288 {
            limb0: 0xa4a7ae8f65ba180c523cb33,
            limb1: 0xb71fabbdc78b1128712d32a5,
            limb2: 0x2acd1052fd0fefa7,
        },
        r1a0: u288 {
            limb0: 0x6ea5598e221f25bf27efc618,
            limb1: 0xa2c2521a6dd8f306f86d6db7,
            limb2: 0x13af144288655944,
        },
        r1a1: u288 {
            limb0: 0xea469c4b390716a6810fff5d,
            limb1: 0xf8052694d0fdd3f40b596c20,
            limb2: 0x24d0ea6c86e48c5c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2e39be614d904bafea58a8cd,
            limb1: 0xf53f0a6a20a1f1783b0ea2d0,
            limb2: 0x99c451b7bb726d7,
        },
        r0a1: u288 {
            limb0: 0x28ec54a4ca8da838800c573d,
            limb1: 0xb78365fa47b5e192307b7b87,
            limb2: 0x2df87aa88e012fec,
        },
        r1a0: u288 {
            limb0: 0xfb7022881c6a6fdfb18de4aa,
            limb1: 0xb9bd30f0e93c5b93ad333bab,
            limb2: 0x1dd20cbccdeb9924,
        },
        r1a1: u288 {
            limb0: 0x16d8dfdf790a6be16a0e55ba,
            limb1: 0x90ab884395509b9a264472d4,
            limb2: 0xeaec571657b6e9d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd963f00409fced03f4666d8b,
            limb1: 0x69da1ce8fdf72af00d994b05,
            limb2: 0x22b579351c2890f2,
        },
        r0a1: u288 {
            limb0: 0xb6503c2bb7eae4639765c01f,
            limb1: 0xc0349c8ba4f12c3a5195de46,
            limb2: 0x6c2d111537216d5,
        },
        r1a0: u288 {
            limb0: 0x2db88f888505684a480c72e,
            limb1: 0x8266df2abf68f8aff18c6253,
            limb2: 0x212786016e278dad,
        },
        r1a1: u288 {
            limb0: 0x42aa3a61bb516c33969fd08b,
            limb1: 0xc6329c4ad2aa3c63c64b315e,
            limb2: 0x4b23903bcf3dd0e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xcb142bbb41b0a3a6f5d9502a,
            limb1: 0xe494a0ee389265e9f2159d55,
            limb2: 0x10b9ca23f92bb794,
        },
        r0a1: u288 {
            limb0: 0xd7959b1b4b51bfaa320e2d9b,
            limb1: 0x4d1c9e19484b3b8da8ed3bf5,
            limb2: 0x2e3cf71a0355eb21,
        },
        r1a0: u288 {
            limb0: 0x80747d91b24c6f67ed9c6aaa,
            limb1: 0x3321fcdc4fb80ac93aff7d86,
            limb2: 0x1e44974873a1dbdc,
        },
        r1a1: u288 {
            limb0: 0xd35e2deb39cb487a4bf8c14c,
            limb1: 0xa2aa6878b544dd0a855600db,
            limb2: 0xd1a1d746f5e8f0b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xce78fc6505db036c10fac771,
            limb1: 0x61f8c0bc7f60ad6415d5e419,
            limb2: 0x59009c5cf9ea663,
        },
        r0a1: u288 {
            limb0: 0xb3b3f697fc34d64ba053b914,
            limb1: 0x317af5815ce5bfffc5a6bc97,
            limb2: 0x23f97fee4deda847,
        },
        r1a0: u288 {
            limb0: 0xf559e09cf7a02674ac2fa642,
            limb1: 0x4fa7548b79cdd054e203689c,
            limb2: 0x2173b379d546fb47,
        },
        r1a1: u288 {
            limb0: 0x758feb5b51caccff9da0f78f,
            limb1: 0xd7f37a1008233b74c4894f55,
            limb2: 0x917c640b4b9627e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x5045f6d1da0c0bdcbffff6be,
            limb1: 0xe9457b4ac2c3e7058fd2d64f,
            limb2: 0x2848319bb43980f4,
        },
        r0a1: u288 {
            limb0: 0x75bd367c1a240763305b8ea0,
            limb1: 0x40c9eb6b096f4954687bfb2d,
            limb2: 0x1d169616fe2c63be,
        },
        r1a0: u288 {
            limb0: 0xc913f04e0f05a2e45b27d62a,
            limb1: 0xf35f6e329c53250ebbbdb848,
            limb2: 0x11c022211adf98f,
        },
        r1a1: u288 {
            limb0: 0x1e81f230f9399cee9dbb5ba6,
            limb1: 0xcb1f6658aa1c290471719165,
            limb2: 0x1cbd8dfc99af325d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x72548e0d946b796842cfecd8,
            limb1: 0x78b54b355e3c26476b0fab82,
            limb2: 0x2dc9f32c90b6ba31,
        },
        r0a1: u288 {
            limb0: 0xa943be83a6fc90414320753b,
            limb1: 0xd708fde97241095833ce5a08,
            limb2: 0x142111e6a73d2e82,
        },
        r1a0: u288 {
            limb0: 0xc79e8d5465ec5f28781e30a2,
            limb1: 0x697fb9430b9ad050ced6cce,
            limb2: 0x1a9d647149842c53,
        },
        r1a1: u288 {
            limb0: 0x9bab496952559362586725cd,
            limb1: 0xbe78e5a416d9665be64806de,
            limb2: 0x147b550afb4b8b84,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x59b8bcfdc64c3865c6561360,
            limb1: 0x894dc65b86c415ffbb3556b1,
            limb2: 0x286e49a2434288f2,
        },
        r0a1: u288 {
            limb0: 0xb67784c58c899b8e9b250083,
            limb1: 0xd8e3b1d09be7f39175444415,
            limb2: 0x1482f027cf5dda00,
        },
        r1a0: u288 {
            limb0: 0x2f6b744c7c67a0dbddae1c0c,
            limb1: 0x7e24df851f5f342231478bb4,
            limb2: 0x861ac9ce009b3c4,
        },
        r1a1: u288 {
            limb0: 0x243b0f1c33d65a530cb7bb89,
            limb1: 0xa334a5c7e196eaf2ce3319d7,
            limb2: 0x62c4c996e7bb82b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1422e11013fe6cdd7f843391,
            limb1: 0xfb96092ab69fc530e27d8d8e,
            limb2: 0xe39e04564fedd0,
        },
        r0a1: u288 {
            limb0: 0xbd4e81e3b4db192e11192788,
            limb1: 0x805257d3c2bdbc344a15ce0d,
            limb2: 0x10ddd4f47445106b,
        },
        r1a0: u288 {
            limb0: 0x87ab7f750b693ec75bce04e1,
            limb1: 0x128ba38ebed26d74d26e4d69,
            limb2: 0x2f1d22a64c983ab8,
        },
        r1a1: u288 {
            limb0: 0x74207c17f5c8335183649f77,
            limb1: 0x7144cd3520ac2e1be3204133,
            limb2: 0xb38d0645ab3499d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb05770306819412dd3f77a9c,
            limb1: 0x5c9f8c96df34bc5514150903,
            limb2: 0x178cee992b31b048,
        },
        r0a1: u288 {
            limb0: 0xe9564ec16b17d5c4340435c2,
            limb1: 0xe85608ffac39e4a7cdc467a3,
            limb2: 0x22a4b6baa7c8105c,
        },
        r1a0: u288 {
            limb0: 0xa49ae2fa009d6f9ef7bd989,
            limb1: 0x23f5ac17bd7922bf508cd102,
            limb2: 0x2244031eabb123f9,
        },
        r1a1: u288 {
            limb0: 0xcd2440a123aab7d10117a766,
            limb1: 0x8cef98304218ac359c36e129,
            limb2: 0x9624bc3963ee9a2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x49173a889c697b0ab07f35bc,
            limb1: 0xdcffb65f4b4c21ced6b623af,
            limb2: 0x1366d12ee6022f7b,
        },
        r0a1: u288 {
            limb0: 0x285fdce362f7a79b89c49b5c,
            limb1: 0xae9358c8eaf26e2fed7353f5,
            limb2: 0x21c91fefaf522b5f,
        },
        r1a0: u288 {
            limb0: 0x748798f96436e3b18c64964a,
            limb1: 0xfc3bb221103d3966d0510599,
            limb2: 0x167859ae2ebc5e27,
        },
        r1a1: u288 {
            limb0: 0xe3b55b05bb30e23fa7eba05b,
            limb1: 0xa5fc8b7f7bc6abe91c90ddd5,
            limb2: 0xe0da83c6cdebb5a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x30a4abff5957209783681bfb,
            limb1: 0x82d868d5ca421e4f1a0daf79,
            limb2: 0x1ba96ef98093d510,
        },
        r0a1: u288 {
            limb0: 0xd9132c7f206a6c036a39e432,
            limb1: 0x8a2dfb94aba29a87046110b8,
            limb2: 0x1fad2fd5e5e37395,
        },
        r1a0: u288 {
            limb0: 0x76b136dc82b82e411b2c44f6,
            limb1: 0xe405f12052823a54abb9ea95,
            limb2: 0xf125ba508c26ddc,
        },
        r1a1: u288 {
            limb0: 0x1bae07f5f0cc48e5f7aac169,
            limb1: 0x47d1288d741496a960e1a979,
            limb2: 0xa0911f6cc5eb84e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x69eabcc53a84ae66dc5e3430,
            limb1: 0x382dd9835c96f675777484f0,
            limb2: 0x2a97bd65e2ec529c,
        },
        r0a1: u288 {
            limb0: 0xfdfb1153f7331898818a0040,
            limb1: 0x89f861af642b43784298c563,
            limb2: 0xa5581ef8ee972a7,
        },
        r1a0: u288 {
            limb0: 0x46f31d516e388c81dcd4217c,
            limb1: 0xbda9ec1f7574c38540a3a175,
            limb2: 0x1e98876044bb96ac,
        },
        r1a1: u288 {
            limb0: 0x56058419ac53abe4a5eb92bf,
            limb1: 0x36de8a3b08085b3be895c430,
            limb2: 0x1b69a40af535fad3,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x56c1b5086ef8d35443144750,
            limb1: 0x6b91f79b113733eb61f5a6e4,
            limb2: 0x115121ec31beef36,
        },
        r0a1: u288 {
            limb0: 0x9739309f74238dd1335f1636,
            limb1: 0x65be6669eb48a7b0e8d4f084,
            limb2: 0x2bb8893503f6154c,
        },
        r1a0: u288 {
            limb0: 0x7a4ab5776b8647fd2daad47e,
            limb1: 0x8be66811aa410119818749ae,
            limb2: 0x1bdf1e62f9041a9d,
        },
        r1a1: u288 {
            limb0: 0xd6a58510606b1f24a4395d6,
            limb1: 0x8c510fc341761d85cebefcfa,
            limb2: 0x5449c6ee8f8db53,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2e7b3a5a35456f42e87968e6,
            limb1: 0xb4303f5093c3a460674a2fcd,
            limb2: 0x2b5331f03b8fa15f,
        },
        r0a1: u288 {
            limb0: 0x7cea371d64d8bd0fc5b9427e,
            limb1: 0x76208e15fc175e352c274fbe,
            limb2: 0x5ceb46647d41234,
        },
        r1a0: u288 {
            limb0: 0x6cdac06bfcf041a30435a560,
            limb1: 0x15a7ab7ed1df6d7ed12616a6,
            limb2: 0x2520b0f462ad4724,
        },
        r1a1: u288 {
            limb0: 0xe8b65c5fff04e6a19310802f,
            limb1: 0xc96324a563d5dab3cd304c64,
            limb2: 0x230de25606159b1e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x36104d723b90b589075eaa6c,
            limb1: 0x606a0b19f33a6b19527a2235,
            limb2: 0x7726c099fbe29f3,
        },
        r0a1: u288 {
            limb0: 0xfc7ee83ebfe26d11a8e7c539,
            limb1: 0x917f73f3dd322fc776136b9d,
            limb2: 0xa16759579ecd215,
        },
        r1a0: u288 {
            limb0: 0x2068cb7ded037c5436a24671,
            limb1: 0x9921a4be01ba5ad98335d3b9,
            limb2: 0x1b7bd322137e97bd,
        },
        r1a1: u288 {
            limb0: 0x6fb54cf936acaccb49d8f5ba,
            limb1: 0x1fd3b9c1bcee48536fb8bcdb,
            limb2: 0x50fecb1933338f9,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb2236e5462d1e11842039bb5,
            limb1: 0x8d746dd0bb8bb2a455d505c1,
            limb2: 0x2fd3f4a905e027ce,
        },
        r0a1: u288 {
            limb0: 0x3d6d9836d71ddf8e3b741b09,
            limb1: 0x443f16e368feb4cb20a5a1ab,
            limb2: 0xb5f19dda13bdfad,
        },
        r1a0: u288 {
            limb0: 0x4e5612c2b64a1045a590a938,
            limb1: 0xbca215d075ce5769db2a29d7,
            limb2: 0x161e651ebdfb5065,
        },
        r1a1: u288 {
            limb0: 0xc02a55b6685351f24e4bf9c7,
            limb1: 0x4134240119050f22bc4991c8,
            limb2: 0x300bd9f8d76bbc11,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe9296a3a3aed4c4143d2e0ba,
            limb1: 0x7de973514b499b2da739b3e6,
            limb2: 0x1b4b807986fcdee0,
        },
        r0a1: u288 {
            limb0: 0xb9295fecce961afe0c5e6dad,
            limb1: 0xc4e30c322bcae6d526c4de95,
            limb2: 0x1fee592f513ed6b2,
        },
        r1a0: u288 {
            limb0: 0x7245f5e5e803d0d448fafe21,
            limb1: 0xcbdc032ecb3b7a63899c53d0,
            limb2: 0x1fde9ffc17accfc3,
        },
        r1a1: u288 {
            limb0: 0x8edcc1b2fdd35c87a7814a87,
            limb1: 0x99d54b5c2fe171c49aa9cb08,
            limb2: 0x130ef740e416a6fe,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x312801404609794c6fdafb8b,
            limb1: 0x8a58c56b36ac96491d7dbb2b,
            limb2: 0x828a2c32ecf04b0,
        },
        r0a1: u288 {
            limb0: 0x4f0f19cc371ad76ac25483af,
            limb1: 0x5c1da48f43b798f0eb6eb528,
            limb2: 0x23c8ea87c21e5bf7,
        },
        r1a0: u288 {
            limb0: 0xedb19187d14d19eb217acd0d,
            limb1: 0xb6ab888b239d2e064a9127e4,
            limb2: 0x23a7867291652f38,
        },
        r1a1: u288 {
            limb0: 0xccfff60f3ec7438e41148471,
            limb1: 0x41e6c17487f42ef1c150643,
            limb2: 0x1f5df83e61c0aef0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x4d6f176a4d27c592aa568955,
            limb1: 0x1c318749c620555b1584f6b8,
            limb2: 0x1ba279464f0e08a2,
        },
        r0a1: u288 {
            limb0: 0xc048b1414f796078fb82b63e,
            limb1: 0xb991bac47bcf4b78bb87adfc,
            limb2: 0x242aba3817f0c0bf,
        },
        r1a0: u288 {
            limb0: 0xe3606591db65da2236c10f45,
            limb1: 0x3317e764fff1c5e46c69423d,
            limb2: 0x1f2ed0d7eb6b7595,
        },
        r1a1: u288 {
            limb0: 0xf52ef0c374da64bd16a3d7aa,
            limb1: 0x8f7bf7f547389b1a38281725,
            limb2: 0x2a2699b6963f8ddd,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x537ecf0916b38aeea21d4e47,
            limb1: 0x181a00de27ba4be1b380d6c8,
            limb2: 0x8c2fe2799316543,
        },
        r0a1: u288 {
            limb0: 0xe68fff5ee73364fff3fe403b,
            limb1: 0x7b8685c8a725ae79cfac8f99,
            limb2: 0x7b4be349766aba4,
        },
        r1a0: u288 {
            limb0: 0xdf7c93c0095545ad5e5361ea,
            limb1: 0xce316c76191f1e7cd7d03f3,
            limb2: 0x22ea21f18ddec947,
        },
        r1a1: u288 {
            limb0: 0xa19620b4c32db68cc1c2ef0c,
            limb1: 0xffa1e4be3bed5faba2ccbbf4,
            limb2: 0x16fc78a64c45f518,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2b6af476f520b4bf804415bc,
            limb1: 0xd949ee7f9e8874698b090fca,
            limb2: 0x34db5e5ec2180cf,
        },
        r0a1: u288 {
            limb0: 0x3e06a324f038ac8abcfb28d7,
            limb1: 0xc2e6375b7a83c0a0145f8942,
            limb2: 0x2247e79161483763,
        },
        r1a0: u288 {
            limb0: 0x708773d8ae3a13918382fb9d,
            limb1: 0xaf83f409556e32aa85ae92bf,
            limb2: 0x9af0a924ae43ba,
        },
        r1a1: u288 {
            limb0: 0xa6fded212ff5b2ce79755af7,
            limb1: 0x55a2adfb2699ef5de6581b21,
            limb2: 0x2476e83cfe8daa5c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8787c11bc029350d77969cc5,
            limb1: 0xa66caa15552eee4ee16e518f,
            limb2: 0x1c8b85f197d63baa,
        },
        r0a1: u288 {
            limb0: 0x9024bea7a9dd7e7b6f693d84,
            limb1: 0x6796660a991607bd993961d5,
            limb2: 0x1173e05d5e6bfd1f,
        },
        r1a0: u288 {
            limb0: 0x44a3672bcfe017b214e70232,
            limb1: 0x738a652b2da3c21e63db8a8d,
            limb2: 0x2008a3fc8c37cfaa,
        },
        r1a1: u288 {
            limb0: 0x46d3d3b1a9215d3fedb582cd,
            limb1: 0xb09599c603f80dd035cf026b,
            limb2: 0x1ac14e44f1c03633,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x66235b10663a6a87c5abf73c,
            limb1: 0xb3a74372073de4a80aba70c5,
            limb2: 0x1ff2ecd156845071,
        },
        r0a1: u288 {
            limb0: 0x41ceb444281c55f68c81c83d,
            limb1: 0xf12ed94492656b4ae10cbd4f,
            limb2: 0x2bf3865ed4fbb136,
        },
        r1a0: u288 {
            limb0: 0x6cd7d10c404817eb2aa976ff,
            limb1: 0x130942247cc90498b6a07d6c,
            limb2: 0xfe08091e81feeff,
        },
        r1a1: u288 {
            limb0: 0x1f4e9435142ed6ecef9593d3,
            limb1: 0x72ad0e78a905da726db92f70,
            limb2: 0x19fa48015af5ff38,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1c4759bcf7c607fe3f839d4d,
            limb1: 0xea91f311da73327e2ed40785,
            limb2: 0x2017052c72360f42,
        },
        r0a1: u288 {
            limb0: 0x38cf8a4368c0709980199fc3,
            limb1: 0xfc9047885996c19e84d7d4ea,
            limb2: 0x1795549eb0b97783,
        },
        r1a0: u288 {
            limb0: 0xb70f7ecfbec0eaf46845e8cc,
            limb1: 0x9ddf274c2a9f89ea3bc4d66f,
            limb2: 0xcc6f106abfcf377,
        },
        r1a1: u288 {
            limb0: 0xf6ff11ce29186237468c2698,
            limb1: 0x5c629ad27bb61e4826bb1313,
            limb2: 0x2014c6623f1fb55e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x988cd017c11a8dba5bbf2706,
            limb1: 0xcf0f68aa622b2a6a203128a2,
            limb2: 0x1087cdb9b0875e02,
        },
        r0a1: u288 {
            limb0: 0x71e9ecd05c311716d609a81e,
            limb1: 0x899a038d278026f768ddb1c0,
            limb2: 0x1c504a57b639d1c5,
        },
        r1a0: u288 {
            limb0: 0xd9867d1c7e3a143c0a25f2c7,
            limb1: 0xb4017ccd3c8506a0cdf39e34,
            limb2: 0x59cf48af2a5d956,
        },
        r1a1: u288 {
            limb0: 0xc93b5abfa6e151e471cf23a2,
            limb1: 0x8bd60a116d2a420eb7f358d7,
            limb2: 0x1d297b587b4cdbb4,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc648054e4b6134bbfd68487f,
            limb1: 0xdf0506dad3f3d098c13a6386,
            limb2: 0x26bebeb6f46c2e8c,
        },
        r0a1: u288 {
            limb0: 0x9d0cdb28a94204776c6e6ba6,
            limb1: 0x303f02dfe619752b1607951d,
            limb2: 0x1127d8b17ef2c064,
        },
        r1a0: u288 {
            limb0: 0xe34ca1188b8db4e4694a696c,
            limb1: 0x243553602481d9b88ca1211,
            limb2: 0x1f8ef034831d0132,
        },
        r1a1: u288 {
            limb0: 0xe3a5dfb1785690dad89ad10c,
            limb1: 0xd690b583ace24ba033dd23e0,
            limb2: 0x405d0709e110c03,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd9a8c97f5b770b977e62e751,
            limb1: 0x74a32fdd7aed3d28b0051be9,
            limb2: 0x2006e3de24bbd202,
        },
        r0a1: u288 {
            limb0: 0x789d9c928f65501142a666d0,
            limb1: 0x8777a6c7447be5aa4458e18,
            limb2: 0x2a949e6454cac57f,
        },
        r1a0: u288 {
            limb0: 0x44751d34b47368c404d0d048,
            limb1: 0xdf779051ca20c85b3f98dd64,
            limb2: 0x146b1f4829b678bb,
        },
        r1a1: u288 {
            limb0: 0x6e742543dbddce77231f461c,
            limb1: 0x86f2d0b0d869c14ff688d023,
            limb2: 0x1581e10dfd0efceb,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x72cc2cef2785ce4ff4e9b7af,
            limb1: 0x60ed5b9c207d7f31fb6234ab,
            limb2: 0x1bb17a4bc7b643ed,
        },
        r0a1: u288 {
            limb0: 0x9424eb15b502cde7927c7530,
            limb1: 0xa0e33edbbaa9de8e9c206059,
            limb2: 0x2b9a3a63bbf4af99,
        },
        r1a0: u288 {
            limb0: 0x423811cb6386e606cf274a3c,
            limb1: 0x8adcc0e471ecfe526f56dc39,
            limb2: 0x9169a8660d14368,
        },
        r1a1: u288 {
            limb0: 0xf616c863890c3c8e33127931,
            limb1: 0xcc9414078a6da6989dae6b91,
            limb2: 0x594d6a7e6b34ab2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbe4e2814c1caffae03dd5dec,
            limb1: 0x3e0bb40c3e630535f3985c5c,
            limb2: 0x28b01edd962835ff,
        },
        r0a1: u288 {
            limb0: 0x666c1ee5d4b5971f84a5bb2c,
            limb1: 0x52f3a385bc7ad6e1619118a8,
            limb2: 0x155e51220a8a361e,
        },
        r1a0: u288 {
            limb0: 0xc31c5295abf34a31ba7a9a5,
            limb1: 0x67429fe882d38b5ce2f77df0,
            limb2: 0x2671de87d27750ec,
        },
        r1a1: u288 {
            limb0: 0x90ec1c79ffca7bcf8b070645,
            limb1: 0x752791c275aadd4d8903fbbb,
            limb2: 0x206756a00056e758,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xf2d619ae78049bf9141c35cf,
            limb1: 0x717f8b10d469a1ee2d91f191,
            limb2: 0x2c72c82fa8afe345,
        },
        r0a1: u288 {
            limb0: 0xb89321223b82a2dc793c0185,
            limb1: 0x71506a0cf4adb8e51bb7b759,
            limb2: 0x2c13b92a98651492,
        },
        r1a0: u288 {
            limb0: 0x4947ef2c89276f77f9d20942,
            limb1: 0xb454d68685ab6b6976e71ec5,
            limb2: 0x19a938d0e78a3593,
        },
        r1a1: u288 {
            limb0: 0xbe883eb119609b489c01c905,
            limb1: 0xaa06779922047f52feac5ce6,
            limb2: 0x76977a3015dc164,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x43a96a588005043a46aadf2c,
            limb1: 0xa37b89d8a1784582f0c52126,
            limb2: 0x22e9ef3f5d4b2297,
        },
        r0a1: u288 {
            limb0: 0x8c6f6d8474cf6e5a58468a31,
            limb1: 0xeb1ce6ac75930ef1c79b07e5,
            limb2: 0xf49839a756c7230,
        },
        r1a0: u288 {
            limb0: 0x82b84693a656c8e8c1f962fd,
            limb1: 0x2c1c8918ae80282208b6b23d,
            limb2: 0x14d3504b5c8d428f,
        },
        r1a1: u288 {
            limb0: 0x60ef4f4324d5619b60a3bb84,
            limb1: 0x6d3090caefeedbc33638c77a,
            limb2: 0x159264c370c89fec,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x28d6da1c4fd4b0e22fa48432,
            limb1: 0x17a43854657906bc6fe7817f,
            limb2: 0x217f7c02a5d112e8,
        },
        r0a1: u288 {
            limb0: 0xcc3663fde0e3b40b91177044,
            limb1: 0xa05019dff5221ed48d86a9d8,
            limb2: 0x17018d1645176b59,
        },
        r1a0: u288 {
            limb0: 0xb92d03f16bcdfb4e744f2d2b,
            limb1: 0x8521ddd1a3eca4f114d08ae2,
            limb2: 0x1ba62d0ad93b822d,
        },
        r1a1: u288 {
            limb0: 0xd198fcd4843f7d47709933cc,
            limb1: 0x5829d62bc1372ddcf382b17f,
            limb2: 0x1e7c70be68bc0a02,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x87ba14bf49492bd047877166,
            limb1: 0x16012f9266ca6b820808d1aa,
            limb2: 0x1b6caaae59ae02b3,
        },
        r0a1: u288 {
            limb0: 0xa4b879a0dfc1a91001a4a5d3,
            limb1: 0x24166b11f7171e59bbbcdca,
            limb2: 0xd8ecbdaff95448a,
        },
        r1a0: u288 {
            limb0: 0x588581411a0216a973a75327,
            limb1: 0x643bf1067acd3ef0ca331519,
            limb2: 0x1cd468be9f698f27,
        },
        r1a1: u288 {
            limb0: 0xe0c9103fc5c8655db432b317,
            limb1: 0xbe5d59b08319657e7247bc18,
            limb2: 0x2d5060ac842f3ca1,
        },
    },
];
