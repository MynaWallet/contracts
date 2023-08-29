// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "@libraries/AccountStorage.sol";
import "@libraries/Errors.sol";
import "@auth/Auth.sol";

abstract contract EIP1271Manager is Auth {
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;
    bytes4 internal constant INVALID_ID = 0xffffffff;
    bytes4 internal constant INVALID_TIME_RANGE = 0xfffffffe;

    event ApproveHash(bytes32 hash);
    event RejectHash(bytes32 hash);

    function approveHash(bytes32 hash) external onlySelf {
        mapping(bytes32 => uint256) storage approvedHashes = _approvedHashes();
        if (approvedHashes[hash] == 1) {
            revert Errors.HASH_ALREADY_APPROVED(hash);
        }
        approvedHashes[hash] = 1;
        emit ApproveHash(hash);
    }

    function rejectHash(bytes32 hash) external onlySelf {
        mapping(bytes32 => uint256) storage approvedHashes = _approvedHashes();
        if (approvedHashes[hash] == 0) {
            revert Errors.HASH_ALREADY_REJECTED(hash);
        }
        approvedHashes[hash] = 0;
        emit RejectHash(hash);
    }

    function _approvedHashes() private view returns (mapping(bytes32 => uint256) storage) {
        return AccountStorage.layout().approvedHashes;
    }
}
