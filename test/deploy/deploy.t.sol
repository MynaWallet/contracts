// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "@account-abstraction/contracts/core/EntryPoint.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "@account-abstraction/contracts/interfaces/UserOperation.sol";

import "@base/MynaWalletFactory.sol";
import "../base/MynaWalletInstance.sol";

contract DeployTest is Test {
    // entrypoint 立ち上げる
    // factory 立ち上げる
    // wallet に fee おくっておく
    // code.size === 0 チェック
    // transfer tokasuru

    EntryPoint public entryPoint;
    MynaWalletInstance public mynaWalletInstance;
    MynaWalletFactory public mynaWalletFactory;

    function setUp() public {
        entryPoint = new EntryPoint();
        mynaWalletFactory = new MynaWalletFactory(entryPoint);
    }

    function testDeploy() public {
        // modulus
        // salt
        // 1. getAddress
        // 2 getCode === 0
        // 3 generate UserOperation
    }
}
