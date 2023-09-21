// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "@account-abstraction/contracts/core/EntryPoint.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "@account-abstraction/contracts/interfaces/UserOperation.sol";

import "@base/MynaWalletFactory.sol";

contract DeployTest is Test {
    EntryPoint public entryPoint;
    MynaWalletFactory public mynaWalletFactory;

    address bundler;
    address alice;

    function setUp() public {
        bundler = vm.addr(0x1);
        alice = vm.addr(0x2);

        entryPoint = new EntryPoint();
        mynaWalletFactory = new MynaWalletFactory(entryPoint);
    }

    function testDeploy() public {
        address sender;
        uint256 nonce;
        bytes memory initCode;
        bytes memory callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        bytes memory paymasterAndData;
        bytes memory signature;

        bytes memory modulus =
            hex"8f6047064f400fd2ff80ad6569c2cffc238079e2cb18648305a59b9f1f389730f9bf9b5e3e436f88065c06241c7189ba43b6adbe5ec7a979d4b42f2a450cd19e8075e5a817b04328a0d16ebfcb6bc09a96020217af6218f3765dbc129131edd004472ab45908bf02ec35b7c044e1c900f7df179fc19c94835802e58c432bc73cee54148a6f24d7316cca195791c87e07e85b07f80b71ddc15b9b053e6f0265a8e81c27c7546dea38cbb951ca71c384892b81df12c8cb0444f9e04d24d0d3323fa857075be26746f4b731a186a51cec24151597b9d31c9ef78db83f27ef0d973d4d2a2d8a9093c7118bf86322603a17d7814a05f6150963b72a275f645a099319";
        uint256 salt = 0;

        // check if the contract is not deployed
        sender = mynaWalletFactory.getAddress(modulus, salt);
        assertTrue(sender.code.length == 0, "address is not zero");

        // generate userOperation
        verificationGasLimit = 1000000;
        preVerificationGas = 150000;
        callGasLimit = 1000000;
        maxFeePerGas = 10 gwei;
        maxPriorityFeePerGas = 10 gwei;
        bytes memory mynaWalletFactoryCall = abi.encodeWithSignature("createAccount(bytes,uint256)", modulus, salt);
        initCode = abi.encodePacked(address(mynaWalletFactory), mynaWalletFactoryCall);

        // generate transfer calldata
        callData = hex"";
        bytes memory executeCall =
            abi.encodeWithSignature("execute(address,uint256,bytes)", address(alice), 1 ether, callData);

        // 3 generate UserOperation
        UserOperation memory userOperation = UserOperation(
            sender,
            nonce,
            initCode,
            executeCall,
            callGasLimit,
            verificationGasLimit,
            preVerificationGas,
            maxFeePerGas,
            maxPriorityFeePerGas,
            paymasterAndData,
            signature
        );

        // bytes32 userOpHash = entryPoint.getUserOpHash(userOperation);
        // console.logBytes32(userOpHash);

        // 4 set actual signature
        signature =
            hex"862ed5b03b54d069bc6fab63502b9942f6b3cf9f8e52c4e4fef90082d399b612e543eebb68d07436c84a11ddae82072ccbd9f645afff3ec6f2e8f2445bbbdb83bfa831befcad9f3c2191dde1b96941ffebd2377218ac2bac2f27752dda1e28ba46710682411d8e169c353824fb0eda3c8d7cbf309099bf53611da27a95841ef5c3b6f21b1e0b16f7f1484f28d1f34e22736b8699da82c01047a2a6bdb942fe10d6e3ff28246da3bd7c35e1edde9a720a7fe609a5dda2ba59b800064ccd41b55bac55da1ce79cdf4e210349dd9be94e71c1c65198c48914221ab22ad67bd55ecfecdda788c2d69450ae877c59cc7ad22e304b97a253d845482f12041b5df0cc1d";
        userOperation.signature = signature;

        UserOperation[] memory userOperations = new UserOperation[](1);
        userOperations[0] = userOperation;

        vm.deal(sender, 42 ether);
        vm.deal(bundler, 1 ether);

        vm.startPrank(bundler);
        entryPoint.handleOps(userOperations, payable(bundler));
        vm.stopPrank();

        // check if the contract is not yet deployed
        assertTrue(sender.code.length != 0, "A2:sender.code.length == 0");
        // check if alice has 1 ether
        assertTrue(alice.balance >= 1 ether, "A3:alice.balance != 1 ether");
    }
}
