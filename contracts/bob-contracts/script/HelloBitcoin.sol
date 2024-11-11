// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {TestLightRelay} from "@bob-collective/bob/relay/TestLightRelay.sol";
import {HelloBitcoin} from "../src/HelloBitcoin.sol";
import {BOBPointOfSale} from "../src/BOBPointOfSale.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HelloWorldScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address usdt = vm.envAddress("USDT_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        TestLightRelay relay = new TestLightRelay();

        HelloBitcoin helloBitcoin = new HelloBitcoin(relay, usdt);

        new BOBPointOfSale(helloBitcoin, IERC20(usdt), address(this));

        vm.stopBroadcast();
    }
}
