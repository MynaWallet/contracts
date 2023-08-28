// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./EntryPointAuth.sol";
import "./OwnerAuth.sol";
import "@libraries/Errors.sol";

abstract contract Auth is EntryPointAuth, OwnerAuth {
    modifier onlySelf() {
        if (msg.sender != address(this)) {
            revert Errors.CALLER_MUST_BE_SELF(msg.sender);
        }
        _;
    }
}
