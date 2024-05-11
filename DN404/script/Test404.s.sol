// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test404} from "../src/Test404.sol";
import "forge-std/Script.sol";

contract Test404script is Script {

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        string memory name = "Test404";
        string memory symbol = "T404";
        uint96 initialTokenSupply = 1000000; // Example value
        address initialSupplyOwner = address(0x123); // Example address
        
        Test404 test404 = new Test404(name, symbol, initialTokenSupply, initialSupplyOwner);
        console.log("Test404 contract deployed at address: ", address(test404));
        
        vm.stopBroadcast();
    }
}

