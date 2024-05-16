// SPDX-License-Identifier: MIT
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
contract StarkStateBridge is Ownable {
    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the StarkWorldID contract 
    uint256  public immutable starkWorldIDAddress;

    /// @notice Ethereum mainnet worldID Address
    address public immutable worldIDAddress;

    /// @notice Starknet Cross Messaging Address
    address public immutable snMessaging;

    /// @notice Amount of gas purchased on Starknet for propagateRoot
    uint32 internal _gasLimitPropagateRoot;

    /// @notice Amount of gas purchased on Starknet for SetRootHistoryExpiry
    uint32 internal _gasLimitSetRootHistoryExpiry;

    /// @notice Amount of gas purchased on Starknet for transferOwnership
    uint32 internal _gasLimitTransferOwnership;

    /// @notice The default gas limit amount to buy on Starknet to do simple transactions
    uint32 public constant DEFAULT_STARK_GAS_LIMIT = 1000000;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when the StateBridge gives ownership of the StarkWorldID contract
    /// @param previousOwner The previous owner of the StarkWorldID contract
    /// @param newOwner The new owner of the StarkWorldID contract
    event OwnershipTransferredStark(
        address indexed previousOwner, address indexed newOwner
    );

    /// @notice Emitted when the StateBridge sends a root to the StarkWorldID contract
    /// @param root The root sent to the StarkWorldID contract on Starknet
    event RootPropagated(uint256 root);

    /// @notice Emitted when the StateBridge sets the root history expiry for StarkWorldID 
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emitted when the StateBridge sets the gas limit for sendRoot
    /// @param _GasLimit The new opGasLimit for sendRoot
    event SetGasLimitPropagateRoot(uint32 _GasLimit);

    /// @notice Emitted when the StateBridge sets the gas limit for SetRootHistoryExpiry
    /// @param _GasLimit The new opGasLimit for SetRootHistoryExpiry
    event SetGasLimitSetRootHistoryExpiry(uint32 _GasLimit);

    /// @notice Emitted when the StateBridge sets the gas limit for transferOwnership
    /// @param _GasLimit The new opGasLimit for transferOwnershipStark
    event SetGasLimitTransferOwnership(uint32 _GasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to set the gas limit to zero
    error GasLimitZero();

    /// @notice Emitted when an attempt is made to set an address to zero
    error AddressZero();

    ///////////////////////////////////////////////////////////////////
    ///                         CONSTRUCTOR                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice constructor
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _starkWorldIDAddress Address of the Starknet Core contract that will receive the new root and timestamp
    /// Stack network
    /// @custom:revert if any of the constructor params addresses are zero
    constructor(
        address _worldIDIdentityManager,
        uint256 _starkWorldIDAddress,
        address _snMessaging
    )  Ownable(msg.sender) {
        if (
            _worldIDIdentityManager == address(0) || _starkWorldIDAddress == uint256(0)
        ) {
            revert AddressZero();
        }

        starkWorldIDAddress = _starkWorldIDAddress;
        worldIDAddress = _worldIDIdentityManager;
        snMessaging = _snMessaging; 
        _gasLimitPropagateRoot = DEFAULT_STARK_GAS_LIMIT;
        _gasLimitSetRootHistoryExpiry = DEFAULT_STARK_GAS_LIMIT;
        _gasLimitTransferOwnership = DEFAULT_STARK_GAS_LIMIT;
    }

    ///////////////////////////////////////////////////////////////////
    ///                          PUBLIC API                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends the latest WorldID Identity Manager root to Starknet
    /// @dev Calls this method on the L1 Proxy contract to relay roots to the destination Starknet
    function propagateRoot() external payable {
        uint256 latestRoot = IWorldIDIdentityManager(worldIDAddress).latestRoot();
        uint256[] memory payload = new uint256[](2);
        payload[0] = latestRoot & (UINT256_PART_SIZE - 1);
        payload[1] = latestRoot >> UINT256_PART_SIZE_BITS; 

        IStarknetMessaging(snMessaging).sendMessageToL2{value: _gasLimitPropagateRoot}(starkWorldIDAddress, HANDLE_RECEIVE_ROOT_SELECTOR, payload);

        emit RootPropagated(latestRoot);
    }

    // @notice Adds functionality to the StateBridge to transfer ownership
    // @param _owner new owner (EOA or contract)
    // @custom:revert if _owner is set to the zero address
    function transferOwnershipStark(address _owner) external payable onlyOwner {
        if (_owner == address(0)) {
            revert AddressZero();
        }

        uint256[] memory payload = new uint256[](1);
        payload[0] = uint256(uint160(_owner)); 

        IStarknetMessaging(snMessaging).sendMessageToL2{value: _gasLimitSetRootHistoryExpiry}(starkWorldIDAddress, HANDLE_TRANSFER_OWNERSHIP_SELECTOR, payload);

   
        emit OwnershipTransferredStark(owner(), _owner);
    }

    /// @notice Adds functionality to the StateBridge to set the root history expiry on Starknet
    /// @param _rootHistoryExpiry new root history expiry
    function setRootHistoryExpiry(uint256 _rootHistoryExpiry) external payable onlyOwner {
        uint256[] memory payload = new uint256[](1);
        payload[0] = _rootHistoryExpiry; 

        IStarknetMessaging(snMessaging).sendMessageToL2{value: _gasLimitTransferOwnership}(starkWorldIDAddress, HANDLE_SET_ROOT_HISTORY_EXPIRY_SELECTOR, payload);


        emit SetRootHistoryExpiry(_rootHistoryExpiry);
    }

    ///////////////////////////////////////////////////////////////////
    ///                         STARK GAS LIMIT                      ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sets the gas limit for the propagateRoot method
    /// @param _starkGasLimit The new gas limit for the propagateRoot method
    function setGasLimitPropagateRoot(uint32 _starkGasLimit) external onlyOwner {
        if (_starkGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitPropagateRoot = _starkGasLimit;

        emit SetGasLimitPropagateRoot(_starkGasLimit);
    }

    /// @notice Sets the gas limit for the SetRootHistoryExpiry method
    /// @param _starkGasLimit The new gas limit for the SetRootHistoryExpiry method
    function setGasLimitSetRootHistoryExpiry(uint32 _starkGasLimit) external onlyOwner {
        if (_starkGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitSetRootHistoryExpiry = _starkGasLimit;

        emit SetGasLimitSetRootHistoryExpiry(_starkGasLimit);
    }

    /// @notice Sets the gas limit for the SetRootHistoryExpiry method
    /// @param _starkGasLimit The new gas limit for the SetRootHistoryExpiry method
    function setGasLimitTransferOwnership(uint32 _starkGasLimit) external onlyOwner {
        if (_starkGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitTransferOwnership = _starkGasLimit;

        emit SetGasLimitTransferOwnership(_starkGasLimit);
    }
}