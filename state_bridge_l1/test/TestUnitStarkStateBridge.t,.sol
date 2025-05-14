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
    uint256 DEFAULT_FEE = 10000000;

    StarkStateBridge starkStateBridge;

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

    uint256 constant TEST_FEE_LIMIT = 111;
    address constant TEST_ADDRESS = address(111);

    function setUp() public {
        starkStateBridge = new StarkStateBridge(worldIDIdentityManager, starkWorldIDAddress, starknetCoreContract);
    }

    function test_SetFeeLimitPropagateRoot() public {
        vm.expectEmit();
        uint256 newFeeLimitPropagateRoot = TEST_FEE_LIMIT;
        emit SetFeeLimitPropagateRoot(newFeeLimitPropagateRoot);
        starkStateBridge.setFeeLimitPropagateRoot(newFeeLimitPropagateRoot);
    }

    function test_SetFeeLimitSetRootHistoryExpiry() public {
        vm.expectEmit();
        uint256 newFeeLimitSetRootHistoryExpiry = TEST_FEE_LIMIT;
        emit SetFeeLimitSetRootHistoryExpiry(newFeeLimitSetRootHistoryExpiry);
        starkStateBridge.setFeeLimitSetRootHistoryExpiry(newFeeLimitSetRootHistoryExpiry);
    }

    function test_SetFeeLimitTransferOwnership() public {
        vm.expectEmit();
        uint256 newFeeLimitTransferOwnership = TEST_FEE_LIMIT;
        emit SetFeeLimitTransferOwnership(newFeeLimitTransferOwnership);
        starkStateBridge.setFeeLimitTransferOwnership(newFeeLimitTransferOwnership);
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
