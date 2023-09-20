// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "@account-abstraction/contracts/core/EntryPoint.sol";
import "@base/MynaWallet.sol";
import "@base/MynaWalletFactory.sol";

contract MynaWalletInstance {
    MynaWalletFactory public mynaWalletFactory;
    MynaWallet public mynaWallet;
    EntryPoint public entryPoint;

    constructor(bytes memory owner, uint256 salt) {
        entryPoint = new EntryPoint();
        mynaWalletFactory = new MynaWalletFactory(entryPoint);

        address walletAddress1 = address(mynaWalletFactory.createAccount(owner, salt));
        address walletAddress2 = mynaWalletFactory.getAddress(owner, salt);
        require(walletAddress1 == walletAddress2, "walletAddress1 != walletAddress2");
        require(walletAddress2.code.length == 0, "wallet code is empty");
        // walletAddress1 as MynaWallet
        mynaWallet = MynaWallet(payable(walletAddress1));
    }
}
