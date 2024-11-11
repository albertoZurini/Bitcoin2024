// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x0362c85df572c00f6ddbb326894dcd3d80721676885c00c7aa65648c040686a1), uint256(0x2c09a09c129cafb00c0e27190d52ef9f2c2d5bf1cbff056df2815de94f81c968));
        vk.beta = Pairing.G2Point([uint256(0x2c66300b366d60310db7b10d4febc5e0a84db7e540d6a60f749c19ff3509dae9), uint256(0x28cfac62e4d90fb15b9b5e4128a60d9cb1952ecea793710a8630cf39182761e4)], [uint256(0x03564d5ff5fd46f776e038db2e811d4b9949f8721cff509f8a70e9a0fadd1375), uint256(0x11fa2b56d52c8f8ac8a80036bf5fd056ff8188cf5e8347f66a12a6dc3449290c)]);
        vk.gamma = Pairing.G2Point([uint256(0x00c94a120fa12a3a5340c0810d1f871f77571a314eb78572c330d4440e61dec0), uint256(0x0c74d38915954d6f28191b590eda92d4b070b20b5a55ec5b16d2e2ddda154e47)], [uint256(0x0afd8fd5b31d95e7674cd4448e643bcbcf56857d39aa8380da2f2514c380b8a5), uint256(0x0daf99ffd4304a437f78ba3984cdc138507b1e1769342474a539eb95f851e961)]);
        vk.delta = Pairing.G2Point([uint256(0x12489570b402d16509e9e23573819abf9d887396d608d361324f8a4c286a5544), uint256(0x2339dddca393a170ca5fed5d1daf3b894c2e66201f77d7ed39e4322a70e138a5)], [uint256(0x0829fae5c590e9ef268b192074d501bc78f5ca2b19ddc841613437476b2222b1), uint256(0x20b0c22a085738036d841b7beea6a6ed43ddeb7d00018f20b9aa934cf6ea1dd6)]);
        vk.gamma_abc = new Pairing.G1Point[](8);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1ea731a627c22d9df11517035b833a69314a3098aca3cb1c49b98524c8562344), uint256(0x2d882f20956f6e7ad48543feb3857e4b66c4120b8ed003e6f6c8ac9e0374c1ed));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0dea4dab12a66119465072878b40f92c2965fafc0cc63871ab76edfc33717015), uint256(0x05debbd4f06aa7bdfb0f2a4cfc4cee95f77794d48b8c9de4da60ec5b03c23d00));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x017eea4ab7759ffc97675931e88cfd6253033c77f10922423885c5ddc7b9c0d0), uint256(0x0bee828fb58e822f87dae1188869d66c10e1c23adbb660f0b2bdbd3fbe7c2aed));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x2f07e23673c9d64347c0966510c820f4bb44f879c401f17ffc1bd91729423123), uint256(0x17e026d7a2077b54f5decfac44c244defbed4a8c9ba45a6b950f7f3801b3111f));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x152ac6cfa80ae92e7e86f6ead16d40fdd014d870d6c9b7043509500121915904), uint256(0x061652612b2f2f1789d95b97912db422e3f756836fdb31d2ed2bae11002af7d4));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x183cbfbbcb640859ed7471770a6721ed83806a05dbaa32d78556c0fc5fe0130f), uint256(0x1081217a41566e49255cd764a826b6fb1bebb7b108013fa442ddbe24e8872901));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2c84b9c57fe6597abc2b4f5f9e60710d44b78084415bf4a6ceb04695c717c95b), uint256(0x1a4f5185767088950e5074f498110d836e3f897fbfddf36256899b277e549d45));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x1da3ed2834c493439580aa8b687b58774436a3476c44bc78201d5038ac8cc96e), uint256(0x083f22c2cebaab37db65ea3eda0f0889fc97db399be9ecf3a682b0d88bd0d848));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[7] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](7);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
