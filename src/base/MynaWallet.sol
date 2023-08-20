// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@account-abstraction/contracts/core/BaseAccount.sol";
import {SolRsaVerify} from "../libraries/RsaVerify.sol";

/// @title MynaWallet
/// @author a42x
/// @notice You can use this contract for ERC-4337 compiant wallet which works with My Number Card
contract MynaWallet is BaseAccount, UUPSUpgradeable, Initializable {
    using SolRsaVerify for bytes32;

    /// @notice Exponent of the RSA public key
    bytes internal constant _EXPONENT =
        hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001";

    /// @notice Part of the RSA public key which can operate this contract
    bytes public modulus;

    /// @notice EntryPoint contract address that can operate this contract
    IEntryPoint private immutable _entryPoint;

    /// @notice Event which will be emitted when this contract is initalized
    event MynaWalletInitialized(IEntryPoint indexed entryPoint, bytes modulus);

    /// @notice Event which will be emmited when this contract owner is changed
    event MynaWalletRecovered(bytes modulus);

    /// @inheritdoc BaseAccount
    function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }

    /// @notice recieve fallback function
    receive() external payable {}

    /**
     * @notice Constructor of MynaWallet (Only used by factory contract)
     * @dev Cusntuctor is only used when factory is deployed and the facotry holds wallet implementation address
     * @param newEntryPoint EntryPoint contract address that can operate this contract
     */
    constructor(IEntryPoint newEntryPoint) {
        _entryPoint = newEntryPoint;
        _disableInitializers();
    }

    /**
     * @dev The _entryPoint member is immutable, to reduce gas consumption.  To upgrade EntryPoint,
     * a new implementation of SimpleAccount must be deployed with the new EntryPoint address, then upgrading
     * the implementation by calling `upgradeTo()`
     * @param newModulus modulus of the RSA public key which can operate this contract
     */
    function initialize(bytes memory newModulus) public virtual initializer {
        _initialize(newModulus);
    }

    /**
     * @notice Execute a transaction (called directly from entryPoint)
     * @param dest target address
     * @param value value to send
     * @param func function call data
     */
    function execute(address dest, uint256 value, bytes calldata func) external {
        _requireFromEntryPoint();
        _call(dest, value, func);
    }

    /**
     * @notice Execute a sequence of transactions (called directory from by entryPoint)
     * @param dest target addresses
     * @param func function call data
     */
    function executeBatch(address[] calldata dest, bytes[] calldata func) external {
        _requireFromEntryPoint();
        require(dest.length == func.length, "MynaWallet: wrong array lengths");
        for (uint256 i = 0; i < dest.length; i++) {
            _call(dest[i], 0, func[i]);
        }
    }

    /**
     * @notice Deposit more funds for this account in the entryPoint
     * @dev This function is payable
     */
    function addDeposit() public payable {
        entryPoint().depositTo{value: msg.value}(address(this));
    }

    /**
     * @notice Withdraw value from the account's deposit
     * @param withdrawAddress target to send to
     * @param amount to withdraw
     */
    function withdrawDepositTo(address payable withdrawAddress, uint256 amount) public {
        _requireFromSelf();
        entryPoint().withdrawTo(withdrawAddress, amount);
    }

    /**
     * @notice Check current account deposit in the entryPoint
     * @return deposit amount
     */
    function getDeposit() public view returns (uint256) {
        return entryPoint().balanceOf(address(this));
    }

    /**
     * @notice Check if the givin signature is valid
     * @param hashed hashed data
     * @param sig signature
     * @param exp exponent of the RSA public key
     * @param mod modulus of the RSA public key
     * @return 0 if valid
     */
    function verifyPkcs1Sha256(bytes32 hashed, bytes memory sig, bytes memory exp, bytes memory mod)
        public
        view
        returns (uint256)
    {
        return hashed.pkcs1Sha256Verify(sig, exp, mod);
    }

    /**
     * @notice Check if the caller is self
     * @dev Internal function
     */
    function _requireFromSelf() internal view {
        //directly through the account
        require(msg.sender == address(this), "MynaWallet: not from account");
    }

    /**
     * @notice Initialize the contract implementation for each proxy contract
     * @dev Each proxy contract must not call constuctor but call initialize once after deployment,
     * @param newModulus modulus of the RSA public key which can operate this contract
     */
    function _initialize(bytes memory newModulus) internal virtual {
        modulus = newModulus;
        emit MynaWalletInitialized(_entryPoint, newModulus);
    }

    /**
     * @notice Validate UserOperation and its signature, currently only supports RSA signature
     * @dev Internal function
     * @param userOp user operation
     * @param userOpHash hash of the user operation
     * @return validationData 0 if valid
     */
    function _validateSignature(UserOperation calldata userOp, bytes32 userOpHash)
        internal
        virtual
        override
        returns (uint256 validationData)
    {
        bytes32 hashed = sha256(abi.encode(userOpHash));
        uint256 ret = verifyPkcs1Sha256(hashed, userOp.signature, _EXPONENT, modulus);
        if (ret != 0) return SIG_VALIDATION_FAILED;
    }

    /**
     * @notice Call a contract with arbitrary data and value
     * @dev Internal function
     * @param target target address
     * @param value value to send
     * @param data function call data
     */
    function _call(address target, uint256 value, bytes memory data) internal {
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function _authorizeUpgrade(address newImplementation) internal view override {
        (newImplementation);
        _requireFromSelf();
    }
}
