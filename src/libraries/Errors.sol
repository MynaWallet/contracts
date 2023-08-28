// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

library Errors {
    error CALLER_MUST_BE_ENTRYPOINT(address sender);
    error CALLER_MUST_BE_SELF(address sender);
    error INVALID_ARRAY_LENGTH(uint256 destLength, uint256 valueLength, uint256 funcLength);
    error INVALID_MODULUS(bytes modulus);
}
