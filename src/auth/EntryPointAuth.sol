// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "@libraries/Errors.sol";

abstract contract EntryPointAuth {
    function _entryPoint() internal view virtual returns (IEntryPoint);

    modifier onlyEntryPoint() {
        if (msg.sender != address(_entryPoint())) {
            revert Errors.CALLER_MUST_BE_ENTRYPOINT(msg.sender);
        }
        _;
    }
}
