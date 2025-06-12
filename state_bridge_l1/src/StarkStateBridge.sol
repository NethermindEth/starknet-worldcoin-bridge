// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.15;

import {IStarkWorldID} from "./interfaces/IStarkWorldID.sol";
import {IRootHistory} from "./interfaces/IRootHistory.sol";
import {IWorldIDIdentityManager} from "./interfaces/IWorldIDIdentityManager.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./starknet/StarknetMessaging.sol";
import "./starknet/Constants.sol";
import "./starknet/IStarknetMessaging.sol";

/// @title World ID State Bridge Starknet
/// @author Worldcoin
/// @notice Distributes new World ID Identity Manager roots to Starknet network
/// @dev This contract lives on Ethereum mainnet and works for Starknet
contract StarkStateBridge is Ownable, IRootHistory {
    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the StarkWorldID contract
    uint256 public starkWorldIDAddress;

    /// @notice Ethereum mainnet worldIDIdentityManager Address
    address public worldIDIdentityManager;

    /// @notice Starknet Cross Messaging Address
    address public starknetCoreContract;

    /// @notice Amount of fee purchased on Starknet for propagateRoot
    uint256 internal _feeLimitPropagateRoot;

    /// @notice Amount of fee purchased on Starknet for SetRootHistoryExpiry
    uint256 internal _feeLimitSetRootHistoryExpiry;

    /// @notice Amount of fee purchased on Starknet for transferOwnership
    uint256 internal _feeLimitTransferOwnership;

    /// @notice The default fee limit for the Starknet Sequencer
    uint256 public constant DEFAULT_STARK_FEE_LIMIT = 0.0001 ether;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when the StateBridge gives ownership of the StarkWorldID contract
    /// @param previousOwner The previous owner of the StarkWorldID contract
    /// @param newOwner The new owner of the StarkWorldID contract
    event OwnershipTransferredStark(address indexed previousOwner, address indexed newOwner);

    /// @notice Emitted when the StateBridge sends a root to the StarkWorldID contract
    /// @param root The root sent to the StarkWorldID contract on Starknet
    event RootPropagated(uint256 root);

    /// @notice Emitted when the StateBridge sets the root history expiry for StarkWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emitted when the StateBridge sets the fee limit for sendRoot
    /// @param _FeeLimit The new FeeLimit for sendRoot
    event SetFeeLimitPropagateRoot(uint256 _FeeLimit);

    /// @notice Emitted when the StateBridge sets the fee limit for SetRootHistoryExpiry
    /// @param _FeeLimit The new FeeLimit for SetRootHistoryExpiry
    event SetFeeLimitSetRootHistoryExpiry(uint256 _FeeLimit);

    /// @notice Emitted when the StateBridge sets the fee limit for transferOwnership
    /// @param _FeeLimit The new FeeLimit for transferOwnershipStark
    event SetFeeLimitTransferOwnership(uint256 _FeeLimit);

    /// @notice Emitted when the StateBridge changes the worldIDIdentityManager
    /// @param _worldIDIdentityManager The new address of worldIDIdentityManager
    event SetWorldIDIdentityManager(address _worldIDIdentityManager);

    /// @notice Emitted when the StateBridge changes the starkWorldIDAddress
    /// @param _starkWorldIDAddress The new address of starkWorldIDAddress
    event SetStarkWorldIDAddress(uint256 _starkWorldIDAddress);

    /// @notice Emitted when the StateBridge changes the starknetCoreContract
    /// @param _starknetCoreContract The new address of starknetCoreContract
    event SetStarknetCoreContract(address _starknetCoreContract);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to set the fee limit to zero
    error FeeLimitZero();

    /// @notice Emitted when an attempt is made to set an address to zero
    error AddressZero();

    /// @notice Emitted when an attempt is made to send messaging fees higher than limit
    error ExceededFeeLimit();

    ///////////////////////////////////////////////////////////////////
    ///                         CONSTRUCTOR                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice constructor
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _starkWorldIDAddress Address of the Starknet Core contract that will receive the new root and timestamp
    /// Stack network
    /// @custom:revert if any of the constructor params addresses are zero
    constructor(address _worldIDIdentityManager, uint256 _starkWorldIDAddress, address _starknetCoreContract)
        Ownable(msg.sender)
    {
        if (_worldIDIdentityManager == address(0) || _starkWorldIDAddress == uint256(0)) {
            revert AddressZero();
        }

        starkWorldIDAddress = _starkWorldIDAddress;
        worldIDIdentityManager = _worldIDIdentityManager;
        starknetCoreContract = _starknetCoreContract;
        _feeLimitPropagateRoot = DEFAULT_STARK_FEE_LIMIT;
        _feeLimitSetRootHistoryExpiry = DEFAULT_STARK_FEE_LIMIT;
        _feeLimitTransferOwnership = DEFAULT_STARK_FEE_LIMIT;
    }

    ///////////////////////////////////////////////////////////////////
    ///                          PUBLIC API                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends the latest WorldID Identity Manager root to Starknet
    /// @dev Calls this method on the L1 Proxy contract to relay roots to the destination Starknet
    function propagateRoot() external payable {
        if (msg.value >= _feeLimitPropagateRoot) {
            revert ExceededFeeLimit();
        }

        uint256 latestRoot = IWorldIDIdentityManager(worldIDIdentityManager).latestRoot();
        uint256[] memory payload = new uint256[](2);
        payload[0] = latestRoot & (UINT256_PART_SIZE - 1);
        payload[1] = latestRoot >> UINT256_PART_SIZE_BITS;

        IStarknetMessaging(starknetCoreContract).sendMessageToL2{value: msg.value}(
            starkWorldIDAddress, HANDLE_RECEIVE_ROOT_SELECTOR, payload
        );

        emit RootPropagated(latestRoot);
    }

    // @notice Adds functionality to the StateBridge to transfer ownership
    // @param _owner new owner (EOA or contract)
    // @custom:revert if _owner is set to the zero address
    function transferOwnershipStark(address _owner) external payable onlyOwner {
        if (msg.value >= _feeLimitTransferOwnership) {
            revert ExceededFeeLimit();
        }

        if (_owner == address(0)) {
            revert AddressZero();
        }

        uint256[] memory payload = new uint256[](1);
        payload[0] = uint256(uint160(_owner));

        IStarknetMessaging(starknetCoreContract).sendMessageToL2{value: msg.value}(
            starkWorldIDAddress, HANDLE_TRANSFER_OWNERSHIP_SELECTOR, payload
        );

        emit OwnershipTransferredStark(owner(), _owner);
    }

    /// @notice Adds functionality to the StateBridge to set the root history expiry on Starknet
    /// @param _rootHistoryExpiry new root history expiry
    function setRootHistoryExpiry(uint256 _rootHistoryExpiry) external payable onlyOwner {
        if (msg.value >= _feeLimitSetRootHistoryExpiry) {
            revert ExceededFeeLimit();
        }

        uint256[] memory payload = new uint256[](2);
        payload[0] = _rootHistoryExpiry & (UINT256_PART_SIZE - 1);
        payload[1] = _rootHistoryExpiry >> UINT256_PART_SIZE_BITS;

        IStarknetMessaging(starknetCoreContract).sendMessageToL2{value: msg.value}(
            starkWorldIDAddress, HANDLE_SET_ROOT_HISTORY_EXPIRY_SELECTOR, payload
        );

        emit SetRootHistoryExpiry(_rootHistoryExpiry);
    }

    ///////////////////////////////////////////////////////////////////
    ///                         STARK FEE LIMIT                     ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sets the fee limit for the propagateRoot method
    /// @param _starkFeeLimit The new fee limit for the propagateRoot method
    function setFeeLimitPropagateRoot(uint256 _starkFeeLimit) external onlyOwner {
        if (_starkFeeLimit <= 0) {
            revert FeeLimitZero();
        }

        _feeLimitPropagateRoot = _starkFeeLimit;

        emit SetFeeLimitPropagateRoot(_starkFeeLimit);
    }

    /// @notice Sets the fee limit for the SetRootHistoryExpiry method
    /// @param _starkFeeLimit The new fee limit for the SetRootHistoryExpiry method
    function setFeeLimitSetRootHistoryExpiry(uint256 _starkFeeLimit) external onlyOwner {
        if (_starkFeeLimit <= 0) {
            revert FeeLimitZero();
        }

        _feeLimitSetRootHistoryExpiry = _starkFeeLimit;

        emit SetFeeLimitSetRootHistoryExpiry(_starkFeeLimit);
    }

    /// @notice Sets the fee limit for the transferOwnershipStark method
    /// @param _starkFeeLimit The new fee limit for the transferOwnershipStark method
    function setFeeLimitTransferOwnership(uint256 _starkFeeLimit) external onlyOwner {
        if (_starkFeeLimit <= 0) {
            revert FeeLimitZero();
        }

        _feeLimitTransferOwnership = _starkFeeLimit;

        emit SetFeeLimitTransferOwnership(_starkFeeLimit);
    }

    ///////////////////////////////////////////////////////////////////
    ///                       ADRESS STORAGE                        ///
    ///////////////////////////////////////////////////////////////////

    function setWorldIDIdentityManager(address _worldIDIdentityManager) external onlyOwner {
        if (_worldIDIdentityManager == address(0)) {
            revert AddressZero();
        }

        worldIDIdentityManager = _worldIDIdentityManager;

        emit SetWorldIDIdentityManager(_worldIDIdentityManager);
    }

    function setStarkWorldIDAddress(uint256 _starkWorldIDAddress) external onlyOwner {
        if (_starkWorldIDAddress == 0) {
            revert AddressZero();
        }

        starkWorldIDAddress = _starkWorldIDAddress;

        emit SetStarkWorldIDAddress(_starkWorldIDAddress);
    }

    function setStarknetCoreContract(address _starknetCoreContract) external onlyOwner {
        if (_starknetCoreContract == address(0)) {
            revert AddressZero();
        }

        starknetCoreContract = _starknetCoreContract;

        emit SetStarknetCoreContract(_starknetCoreContract);
    }
}
