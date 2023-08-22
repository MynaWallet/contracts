// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

library Errors {
    error InvalidArrayLength(uint256 destLength, uint256 funcLength);
    error NotFromAccount(address sender);
}
