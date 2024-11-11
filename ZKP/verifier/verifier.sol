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
        vk.alpha = Pairing.G1Point(uint256(0x2c1dd2d932c210fb9e0862a136d8ff253eb070590e75e46b7975d03d6bed9318), uint256(0x0d2edf63000caf2418cc63c2d48d20b149c539d390297202d6875e99794dcd48));
        vk.beta = Pairing.G2Point([uint256(0x22ccaccaf15f1ecb27413bfd2f2e9de3d9623b58c4062b2a3a635dea674f1d99), uint256(0x066787e7be7ebd7602cf4b2224057362cf0557016956446203beaad89f34e60e)], [uint256(0x10a54e24c5ee3d101cdc18db563bf74e50647e2ec8c27864c3cf11fcf6f8b99e), uint256(0x15b14fc25e2ced83dc83277e9e1aa8ea3607d1a172922b7418244fdfe40abd6d)]);
        vk.gamma = Pairing.G2Point([uint256(0x12acde3e21a99fa4863b4bc153ccb37fce1841afcda62d8ecfecdc2cc441e3ca), uint256(0x19f1402997205efbf1baa8cac84a7852732660b395fbf6e387d0158e9fd1e048)], [uint256(0x2426eaac26fdd7f539b446388ff58c04a996039e1a56a6590d9b4e3359d145e5), uint256(0x1276e26dc003629ae249a78c1bd33525504cd6a21316b3e04e077aa0e2ad5621)]);
        vk.delta = Pairing.G2Point([uint256(0x077a2ec0310bdf0009017ee92736dde7d6d82748742529940b759a432f6a22ba), uint256(0x2752605f2e79acb5e3a98e8b60e74d9ecb1c0ea5534c46208e91ab063bde53b8)], [uint256(0x13bfe29464e4cd93441790204836fbf6a3ad33331bed5727a47a1df2a256b6c4), uint256(0x080a8765e7532cbc2415b7e4f7f433a36253a22eca571a81960f4228571a7896)]);
        vk.gamma_abc = new Pairing.G1Point[](8);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x08a027c9f4597c4490feee4c757fd6bb9469929ac191c6b0056ce8d2622457f9), uint256(0x28a4832f094cb2d3f603ec11ca32e2d7766860d198853541ba7858dddbd2f39f));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2300db292778f3ad35dfdb43cf0ce88bc109a63ce0a14f5b84e2a8acdafdd99d), uint256(0x2c779964e63be3176e69f22ae1b8952ec05945baa5ff6a512344a8730b049aba));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0e9d4fd467ee51d7e4a4aeb37aa994a0d1ef297eafa3b77266e7c900c289fc0a), uint256(0x02a92f68e2d2577fd1296ba84e499a0759e1ed7e2976a7a77755e2bef7e966b9));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1c97eaace47ba45dcde631ad0c37b1c8e37cb6f8911a152a3af4cdc2ede5a034), uint256(0x208eef38674c1518b209ed9a0143b312d58768f7a2409c2ec3035b48128662eb));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x04c27441c1b939051660c65572461441957ce18b726858a2f1943ec695057daf), uint256(0x140734f8a1a8f9a6dc7b522511f76ee5169f847c4543efd1b46bf7ed22401dea));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x263069e025ec83b33b72228ecf0424725885b4360775bcdfebc2a6038857dc87), uint256(0x1a5c4023d448956a87ed557704d21cee2098360d49e3d90d30ed804a98ed4574));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x1b2b4d60f43590796fc9737cf439f868b84f61c9c7eb1fc0ca7e875ec00e29d0), uint256(0x27f5f98cb160ba9e179e785e032a2082afd39c4fede34a84655b9ba86fdd9ed9));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x26f5ae0a1ad9e25d7768ef3c59979624d80150fd1a0c0d306d6a5c53ee527e13), uint256(0x2207776c3ce338dd81fdbb2240d310d82082b061d68d3387751cffd24870c58d));
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
