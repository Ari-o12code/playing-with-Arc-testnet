// script/DeployV3.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/HelloArchitect.sol";

contract DeployV3 is Script {
    function run() external {
        vm.startBroadcast();
        new HelloArchitectV3();
        vm.stopBroadcast();
    }
}
