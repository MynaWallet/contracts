// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "@base/MynaWallet.sol";
import "@account-abstraction/contracts/core/EntryPoint.sol";

contract MynaWalletLogicInstance {
    MynaWallet public MynaWalletLogic;

    constructor(EntryPoint _entryPoint) {
        MynaWalletLogic = new MynaWallet(_entryPoint);
    }
}
