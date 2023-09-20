// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "@libraries/AccountStorage.sol";
import "@libraries/Errors.sol";
import "@auth/OwnerAuth.sol";

abstract contract OwnerManager is OwnerAuth {
    uint256 private constant _MODULUS_LENGTH = 256;
    /// @notice Exponent of the RSA public key
    bytes internal constant _EXPONENT =
        hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001";

    event OwnerChanged(bytes newOwner, bytes oldOwner);

    function getOwner() public view returns (bytes memory owner, bytes memory exponent) {
        return (AccountStorage.layout().owner, _EXPONENT);
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

    function _isOwner(bytes memory modulus) internal view override returns (bool) {
        return keccak256(AccountStorage.layout().owner) == keccak256(modulus);
    }
}
