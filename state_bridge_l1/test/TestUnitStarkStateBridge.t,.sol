// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/starknet/StarknetMessaging.sol";
import "../src/StarkStateBridge.sol";
import "../src/mock/MockWorldIDIdentityManager.sol";

contract UnitStarkStateBridge is Test {
    address worldIDIdentityManager = vm.envAddress("WORLD_ID_IDENTITY_MANAGER");
    uint256 starkWorldIDAddress = vm.envUint("STARK_WORLD_ID_ADDRESS");
    address starknetCoreContract = vm.envAddress("SN_MESSAGING_ADDRESS");
    uint256 DEFAULT_GAS = 10000000;

    StarkStateBridge starkStateBridge;

    /// @notice Emitted when the StateBridge sets the gas limit for sendRoot
    /// @param _GasLimit The new GasLimit for sendRoot
    event SetGasLimitPropagateRoot(uint256 _GasLimit);

    /// @notice Emitted when the StateBridge sets the gas limit for SetRootHistoryExpiry
    /// @param _GasLimit The new GasLimit for SetRootHistoryExpiry
    event SetGasLimitSetRootHistoryExpiry(uint256 _GasLimit);

    /// @notice Emitted when the StateBridge sets the gas limit for transferOwnership
    /// @param _GasLimit The new GasLimit for transferOwnershipStark
    event SetGasLimitTransferOwnership(uint256 _GasLimit);

    /// @notice Emitted when the StateBridge changes the worldIDIdentityManager
    /// @param _worldIDIdentityManager The new address of worldIDIdentityManager
    event SetWorldIDIdentityManager(address _worldIDIdentityManager);
    
    /// @notice Emitted when the StateBridge changes the starkWorldIDAddress
    /// @param _starkWorldIDAddress The new address of starkWorldIDAddress
    event SetStarkWorldIDAddress(uint256 _starkWorldIDAddress);
    
    /// @notice Emitted when the StateBridge changes the starknetCoreContract
    /// @param _starknetCoreContract The new address of starknetCoreContract
    event SetStarknetCoreContract(address _starknetCoreContract);

    uint256 constant TEST_GAS_LIMIT = 111; 
    address constant TEST_ADDRESS = address(111); 
    
    function setUp() public {
        starkStateBridge = new StarkStateBridge(worldIDIdentityManager, starkWorldIDAddress, starknetCoreContract);
    }


    function test_SetGasLimitPropagateRoot() public {
        vm.expectEmit();
        uint256 newGasLimitPropagateRoot = TEST_GAS_LIMIT; 
        emit SetGasLimitPropagateRoot(newGasLimitPropagateRoot);
        starkStateBridge.setGasLimitPropagateRoot(newGasLimitPropagateRoot);
    }

    function test_SetGasLimitSetRootHistoryExpiry() public {
        vm.expectEmit();
        uint256 newGasLimitSetRootHistoryExpiry = TEST_GAS_LIMIT; 
        emit SetGasLimitSetRootHistoryExpiry(newGasLimitSetRootHistoryExpiry);
        starkStateBridge.setGasLimitSetRootHistoryExpiry(newGasLimitSetRootHistoryExpiry);
    }

    function test_SetGasLimitTransferOwnership() public {
        vm.expectEmit();
        uint256 newGasLimitTransferOwnership = TEST_GAS_LIMIT; 
        emit SetGasLimitTransferOwnership(newGasLimitTransferOwnership);
        starkStateBridge.setGasLimitTransferOwnership(newGasLimitTransferOwnership);
    }

    function test_SetWorldIDIdentityManager() public {
        vm.expectEmit();
        address newWorldIDIdentityManager = TEST_ADDRESS;
        emit SetWorldIDIdentityManager(newWorldIDIdentityManager);
        starkStateBridge.setWorldIDIdentityManager(newWorldIDIdentityManager);
    }

    function test_SetStarkWorldIDAddress() public {
        vm.expectEmit();
        uint256 newStarkWorldIDAddress = 111;
        emit SetStarkWorldIDAddress(newStarkWorldIDAddress);
        starkStateBridge.setStarkWorldIDAddress(newStarkWorldIDAddress);
    }

    function test_SetStarknetCoreContract() public {
        vm.expectEmit();
        address newStarknetCoreContract = TEST_ADDRESS;
        emit SetStarknetCoreContract(newStarknetCoreContract);
        starkStateBridge.setStarknetCoreContract(newStarknetCoreContract);
    }

    function testFail_SetWorldIDIdentityManager() public {
        address zero_address = address(0); 
        starkStateBridge.setWorldIDIdentityManager(zero_address);
    }
    
    function testFail_SetStarkWorldIDAddress() public {
        uint256 zero_address = 0;
        starkStateBridge.setStarkWorldIDAddress(zero_address);
    }

    function testFail_SetStarknetCoreContract() public {
        address zero_address = address(0); 
        starkStateBridge.setStarknetCoreContract(zero_address);
    }
    
    function testFail_TransferOwnershipStark() public {
        address zero_address = address(0); 
        starkStateBridge.transferOwnership(zero_address); 
    }

    receive() external payable {}
}