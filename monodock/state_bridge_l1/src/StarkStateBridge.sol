// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;


import {IStarkWorldID} from "./interfaces/IStarkWorldID.sol";
import {IRootHistory} from "./interfaces/IRootHistory.sol";
import {IWorldIDIdentityManager} from "./interfaces/IWorldIDIdentityManager.sol";
import {Ownable2Step} from "openzeppelin-contracts/access/Ownable2Step.sol";
import "./starknet/IStarknetMessaging.sol";

/// @title World ID State Bridge Starknet
/// @author Worldcoin
/// @notice Distributes new World ID Identity Manager roots to Starknet network
/// @dev This contract lives on Ethereum mainnet and works for Starknet 
contract StarkStateBridge is Ownable2Step {
    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the StarkWorldID contract 
    address public immutable starkWorldIDAddress;

    /// @notice Ethereum mainnet worldID Address
    address public immutable worldIDAddress;

    /// @notice Amount of gas purchased on Starknet for propagateRoot
    uint32 internal _gasLimitPropagateRoot;

    /// @notice Amount of gas purchased on Starknet for SetRootHistoryExpiry
    uint32 internal _gasLimitSetRootHistoryExpiry;

    /// @notice Amount of gas purchased on Starknet for transferOwnershipOp
    //uint32 internal _gasLimitTransferOwnership;

    /// @notice The default gas limit amount to buy on Starknet to do simple transactions
    uint32 public constant DEFAULT_OP_GAS_LIMIT = 1000000;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism/OP Stack chain EOA/contract)
    /// or an Ethereum EOA or contract
    // event OwnershipTransferredOp(
    //     address indexed previousOwner, address indexed newOwner, bool isLocal
    // );

    /// @notice Emitted when the StateBridge sends a root to the OPWorldID contract
    /// @param root The root sent to the OPWorldID contract on the OP Stack chain
    event RootPropagated(uint256 root);

    /// @notice Emitted when the StateBridge sets the root history expiry for OpWorldID and PolygonWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emitted when the StateBridge sets the gas limit for sendRootOp
    /// @param _opGasLimit The new opGasLimit for sendRootOp
    event SetGasLimitPropagateRoot(uint32 _opGasLimit);

    /// @notice Emitted when the StateBridge sets the gas limit for SetRootHistoryExpiry
    /// @param _opGasLimit The new opGasLimit for SetRootHistoryExpiry
    event SetGasLimitSetRootHistoryExpiry(uint32 _opGasLimit);

    /// @notice Emitted when the StateBridge sets the gas limit for transferOwnershipOp
    /// @param _opGasLimit The new opGasLimit for transferOwnershipOptimism
    //event SetGasLimitTransferOwnershipOp(uint32 _opGasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to renounce ownership.
    error CannotRenounceOwnership();

    /// @notice Emitted when an attempt is made to set the gas limit to zero
    error GasLimitZero();

    /// @notice Emitted when an attempt is made to set an address to zero
    error AddressZero();

    ///////////////////////////////////////////////////////////////////
    ///                         CONSTRUCTOR                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice constructor
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _opWorldIDAddress Address of the Optimism contract that will receive the new root and timestamp
    /// Stack network
    /// @custom:revert if any of the constructor params addresses are zero
    constructor(
        address _worldIDIdentityManager,
        address _starkWorldIDAddress
    ) {
        if (
            _worldIDIdentityManager == address(0) || _starkWorldIDAddress == address(0)
        ) {
            revert AddressZero();
        }

        opWorldIDAddress = _opWorldIDAddress;
        starkIDAddress = _starkWorldIDAddress;
        _gasLimitPropagateRoot = DEFAULT_OP_GAS_LIMIT;
        _gasLimitSetRootHistoryExpiry = DEFAULT_OP_GAS_LIMIT;
        _gasLimitTransferOwnership = DEFAULT_OP_GAS_LIMIT;
    }

    ///////////////////////////////////////////////////////////////////
    ///                          PUBLIC API                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends the latest WorldID Identity Manager root to the IOpStack.
    /// @dev Calls this method on the L1 Proxy contract to relay roots to the destination OP Stack chain
    function propagateRoot() external {
        uint256 latestRoot = IWorldIDIdentityManager(worldIDAddress).latestRoot();

        // TODO:


        emit RootPropagated(latestRoot);
    }

    /// @notice Adds functionality to the StateBridge to transfer ownership
    /// of OpWorldID to another contract on L1 or to a local OP Stack chain EOA
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Optimism, false if it is a cross-domain owner
    /// @custom:revert if _owner is set to the zero address
    // function transferOwnershipOp(address _owner, bool _isLocal) external onlyOwner {
    //     if (_owner == address(0)) {
    //         revert AddressZero();
    //     }

    //     // The `encodeCall` function is strongly typed, so this checks that we are passing the
    //     // correct data to the OP Stack chain bridge.
    //     bytes memory message =
    //         abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (_owner, _isLocal));

    //     ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
    //         // Contract address on the OP Stack Chain
    //         opWorldIDAddress,
    //         message,
    //         _gasLimitTransferOwnership
    //     );

    //     emit OwnershipTransferredOp(owner(), _owner, _isLocal);
    // }

    /// @notice Adds functionality to the StateBridge to set the root history expiry on OpWorldID
    /// @param _rootHistoryExpiry new root history expiry
    function setRootHistoryExpiry(uint256 _rootHistoryExpiry) external onlyOwner {
        
        // TODO:

        emit SetRootHistoryExpiry(_rootHistoryExpiry);
    }

    ///////////////////////////////////////////////////////////////////
    ///                         STARK GAS LIMIT                      ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sets the gas limit for the propagateRoot method
    /// @param _opGasLimit The new gas limit for the propagateRoot method
    function setGasLimitPropagateRoot(uint32 _starkGasLimit) external onlyOwner {
        if (_starkGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitPropagateRoot = _starkGasLimit;

        emit SetGasLimitPropagateRoot(_starkGasLimit);
    }

    /// @notice Sets the gas limit for the SetRootHistoryExpiry method
    /// @param _opGasLimit The new gas limit for the SetRootHistoryExpiry method
    function setGasLimitSetRootHistoryExpiry(uint32 _starkGasLimit) external onlyOwner {
        if (_starkGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitSetRootHistoryExpiry = _starkGasLimit;

        emit SetGasLimitSetRootHistoryExpiry(_starkGasLimit);
    }

    /// @notice Sets the gas limit for the transferOwnershipOp method
    /// @param _opGasLimit The new gas limit for the transferOwnershipOp method
    // function setGasLimitTransferOwnershipOp(uint32 _opGasLimit) external onlyOwner {
    //     if (_opGasLimit <= 0) {
    //         revert GasLimitZero();
    //     }

    //     _gasLimitTransferOwnership = _opGasLimit;

    //     emit SetGasLimitTransferOwnershipOp(_opGasLimit);
    // }

    ///////////////////////////////////////////////////////////////////
    ///                          OWNERSHIP                          ///
    ///////////////////////////////////////////////////////////////////
    /// @notice Ensures that ownership of WorldID implementations cannot be renounced.
    /// @dev This function is intentionally not `virtual` as we do not want it to be possible to
    ///      renounce ownership for any WorldID implementation.
    /// @dev This function is marked as `onlyOwner` to maintain the access restriction from the base
    ///      contract.
    // function renounceOwnership() public view override onlyOwner {
    //     revert CannotRenounceOwnership();
    // }
}