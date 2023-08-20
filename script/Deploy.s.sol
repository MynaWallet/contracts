// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@account-abstraction/contracts/core/EntryPoint.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "../src/base/MynaWalletFactory.sol";

contract DeployLocal is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        EntryPoint entryPoint = new EntryPoint();
        MynaWalletFactory factory = new MynaWalletFactory(entryPoint);
        console.log("Deployed entryPoint at: ", address(entryPoint));
        console.log("Deployed factory at: ", address(factory));
        vm.stopBroadcast();
    }
}

contract DeployFactory is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        address entryPointAddress = vm.envAddress("ENTRY_POINT_ADDRESS");

        MynaWalletFactory factory = new MynaWalletFactory(
            IEntryPoint(entryPointAddress)
        );
        console.log("Deployed factory at: ", address(factory));
        vm.stopBroadcast();
    }
}
