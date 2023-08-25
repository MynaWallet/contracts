// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

library AccountStorage {
    bytes32 private constant _ACCOUNT_SLOT = keccak256("MynaWallet.AccountStorage");

    struct Layout {
        // base account storage
        bytes owner;
        uint256[50] gap0;

        // TODO session key storage

        // TODO recovery key storage
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = _ACCOUNT_SLOT;
        assembly ("memory-safe") {
            l.slot := slot
        }
    }
}
