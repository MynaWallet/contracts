// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "@libraries/AccountStorage.sol";
import "@libraries/Errors.sol";

abstract contract OwnerManager {
    uint256 private constant _MODULUS_LENGTH = 256;

    event OwnerChanged(bytes newOwner, bytes oldOwner);

    function getOwner() public view returns (bytes memory) {
        return AccountStorage.layout().owner;
    }

    function isOwner(bytes memory modulus) public view returns (bool) {
        return _isOwner(modulus);
    }

    function _setOwner(bytes memory newOwner) internal {
        if (newOwner.length != _MODULUS_LENGTH) {
            revert Errors.INVALID_MODULUS(newOwner);
        }
        bytes memory oldOwner = AccountStorage.layout().owner;
        AccountStorage.layout().owner = newOwner;
        emit OwnerChanged(newOwner, oldOwner);
    }

    function _isOwner(bytes memory modulus) internal view returns (bool) {
        return keccak256(AccountStorage.layout().owner) == keccak256(modulus);
    }
}
