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
        vk.alpha = Pairing.G1Point(uint256(0x1e14404c692f3fa7e9727bc811491e7eb48e2290c08c5a9e8cd85a0c4aa2c109), uint256(0x176f0232b59f891ce32e11e6ed9ba3a9e6225830d052d446b7da6680ba8def17));
        vk.beta = Pairing.G2Point([uint256(0x2290d9da177f0ce74c0f8f2a413dbe0296aa6ec9bf6155824eab05932ce77f42), uint256(0x1fd55c5d793ab9c570e786733061b7c4e64aae5a3f8a25ff8c799467bd4800dd)], [uint256(0x26aa38c8748a7d2d7ed54d56fe949fd08bccd8dfc80b55541c78fd858b421e3d), uint256(0x1d28882ae7556f7e68b8999e0e526d66e9ec33a5dc440fd0d30e8c2b85e83bc9)]);
        vk.gamma = Pairing.G2Point([uint256(0x013b6b4de81ed6065dce2f8551642571d800cda180e550d12defee5902ecbb6c), uint256(0x0b5e0c1e11f11cbacb3ad333b5a467ca19655d3597d0c7099297806ce1ba9cca)], [uint256(0x1f85f592c5afcf12e59b6c7d61af8d088d3d25b2f89f7f77a5d2178475ee2ecd), uint256(0x02e50dde8788cd5e5dc747fd7512339c5c92401d5fa69caa6968aad0645c0849)]);
        vk.delta = Pairing.G2Point([uint256(0x1b70c4e85ee5162c0f22d268e75c62f1ee35a67d6210b3115998bbffa85c903e), uint256(0x2c4e91ff1ade47e8a0cba23d3cd5ef179009f6b5678ed87b1627933680771c15)], [uint256(0x00d0f1391b3ace4c558ed87cb3ad6ad3b38ee1f186231e61f8a378c03f283d05), uint256(0x0ded026a853d3bdc0482a5da2931dce6d9f65c47389651614eeacb8f336f143a)]);
        vk.gamma_abc = new Pairing.G1Point[](8);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x10e39bfb49d8c8c9c753610dfae67d7d76f2b9ee0cd6f069dd472e97e5d90993), uint256(0x2988e8d1e83d89f76f19d9bf884eacaa0f2d6bbf54e049426dba44b6cb19a36f));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1785473c4c95f3415666d612cb0aa5c6568987a988c691d7408b695be1f6c7af), uint256(0x044d83db1f7e39c31fa81bf57009b204323e9188adc4b2162c1b1e4faa0846a0));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1635206f18254be3964b68274c574540901ae93adb9c88496d4e2e9ebb9a66ab), uint256(0x030ef98961d5d03afba21086c09d14a42563a309f440dd497b405de691c1005e));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x2cc4a25893578ea66bba377288cf962cb2deee2300b538fe5f9cf06b5a10b4b5), uint256(0x1c01b265acb2640d7e87a2c617566ca746fa1a40a6baf3f67f0d8c6577aa74d7));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x23dcabf185ff2ba19a81c01f7680fe1d587509ed390260ff7c2a8b17b8bb1ec6), uint256(0x22849a708328ec57d568e1a6992f397f0f97ab23b45c554eab679d0d86e8c0d4));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x046e9752d4b53d5ae74cb90e7e8c3a36187e1a92741552e0675de96fbaadc390), uint256(0x2322157ec9ecd9b6a535f222f476a0b8898456d4e2ecfcd829fcceb977a10117));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x12709454873815b111f6707456f5aaf37da751f13a6e16f0e49a3a2edfe20c9a), uint256(0x1fbc660f44da3a9d3cd4357f0f1b755a53b32648fe030c71d674679dd6a491bd));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x18ab7b7a649b61678d5bc6ea270bf64a129ad7ea311676586bfba44cbc48831f), uint256(0x025d175cfc91f44afba52db6b9bef6bf478909c0a42f597468e445b5392659ec));
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
