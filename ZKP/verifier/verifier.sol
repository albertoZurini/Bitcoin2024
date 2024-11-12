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
        vk.alpha = Pairing.G1Point(uint256(0x1b7e63b573ad7e1cfd8f835a769a098eea817f51b1fef6368bc04d6e6d374678), uint256(0x1a100cea1d372dba4ceb8800080fb9f2fae36bb233f4a9b6fac155cee1c784bb));
        vk.beta = Pairing.G2Point([uint256(0x2f955eb262324be7b450e2851ef7a691cc19e5b5e834eeca3c68d7588389ba21), uint256(0x28050075d37835bd0476aea02e9350004a8a3fe860fa6526789796aa985e8fe0)], [uint256(0x1e5034a431b3bda001fa44ffdd209d6e9fcb68f9e10ae7f5387f9af8efef9976), uint256(0x16f69087d20d37cccfc9e3b9b67dd53d3f39029e4c3fe70d761a698d184fbbf1)]);
        vk.gamma = Pairing.G2Point([uint256(0x04b97dd69bef43b59925a80717d82e303dd84aaa95161b4a0420d6f2cc588c1b), uint256(0x21bfcdd505a9a533877f725ad1ff05a274cc83fb6c8ab51647dec15bb22ce8dd)], [uint256(0x12a51afdc484b87eca1888ea3232abe685de455deb1a05f9c78b9c1932505a67), uint256(0x2e0aa5b9c1c1405595db05770e755da28096405217078d3c984afc8be2396318)]);
        vk.delta = Pairing.G2Point([uint256(0x0c2b84b99b5b0a24dbe5a68a3323863c3229bdc34746b68d409e44a66bff4335), uint256(0x00385d445a873be24782d379dffde3acfe0bfc49cdbf83f3ef2866acb283f1ad)], [uint256(0x0e2621b59e7c60338ba274983ff270f4efc76fcd55a9c9f1f387b893ae424a26), uint256(0x130bc26944a1a127b1fea26c6ad31f8bf307f016f206fa0c9b4f34fb2916e674)]);
        vk.gamma_abc = new Pairing.G1Point[](9);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2ba801e57cb8d8dccef3c4aafb48b56f51aebbeeb793cb1688a8d3aa287cd065), uint256(0x04dfea7af096e769fdbd26071075286974b5bacde600fa6bdb4afb73ad79eed5));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2c287c4c1eccddf29f5f323fbf6c123621a48f1c408d61ec41028c14f88a5098), uint256(0x2eee84cd9e498a4dc2d7f48e087e289f7a52c0a9c01b3ed578d85e4d3c371003));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0c8fa69a419759926012565efff3723dfd91c75ee9c80319cc949e8179c12b19), uint256(0x2e444e06a82c780c4ff87673bd7e4e7d02d3282087ce6b6c7ea231885573f974));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1769cfead5c18194e5f04467c7462f1402feebc38a76e096bb3363d71907c749), uint256(0x283220b50afc92e4c88a16b213f4444c7b161f193c08b0911fc8f7fa458df155));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x1e2771d6958a24dd2a3105d1354343d756b6049fe86905bb7abd9d9ee3dafca1), uint256(0x24238f594b68fae54c62ee7c29b0069df8d97b61e4a4821a0497544264f35436));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x01f99ae862abfd5745a8c714d791841d3387247c3b8824cb1a1f92b75a02b80a), uint256(0x1d3a2dc0e2996b5370da6426f2963c92c168f98e52bde12a64de61e7e16bb660));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x01d8d09a8b5db3195c233ba9795f88ca4f8356b8ec96b8b556f2291546fa7a0c), uint256(0x2d4882d6ac5262d71e07e07a62fad42881fea4cc665890665ce421441bebd721));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x25bcdfa80965bd93e72c04e01b45aa45bfcce572b0f827028e981aa3c2c8d326), uint256(0x126c0b8e054f7b6d6eb7225ed150a5303e51d12c746f7ca6cb50889e1a5ffd6e));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x059ebd484db2d65c035ed808cc2bb7e650a88ff3067c3a99ef72f75538d88c27), uint256(0x2e4ed261105dd384abe4455cedb567f754263acf7fb2bcefe0df919ee38b71be));
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
            Proof memory proof, uint[8] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](8);
        
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
