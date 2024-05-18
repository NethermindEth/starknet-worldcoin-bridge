// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "../src/starknet/StarknetMessaging.sol";
import "../src/StarkStateBridge.sol";
import "../src/mock/MockWorldIDIdentityManager.sol";

contract TestStarkStateBridge is Script {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    uint256 starkWorldIDAddress = vm.envUint("STARK_WORLD_ID_ADDRESS");
    StarkStateBridge starkStateBridge = StarkStateBridge(vm.envAddress("STARK_STATE_BRIDGE"));
    MockWorldIDIdentityManager mockWorldIDIdentityManager = MockWorldIDIdentityManager(vm.envAddress("WORLD_ID_IDENTITY_MANAGER"));
    uint256 immutable DEFAULT_GAS = 1000000;
    function run() public{
        vm.startBroadcast(deployerPrivateKey);

        runRootExpiryTest(); 
        runTransferOwner(); 

        vm.stopBroadcast();
    }

    function runRootPropogation() public {
        starkStateBridge.propagateRoot{value: DEFAULT_GAS}();
        mockWorldIDIdentityManager.incrementRoot(); // mock function to simulate new root
    }

    function runRootExpiryTest() public {
        // Setup
        runRootPropogation();
        runRootPropogation();   

        // Trigger error 
        starkStateBridge.propagateRoot{value: DEFAULT_GAS}(); // Error CANNOT_OVERWRITE_ROOT
        mockWorldIDIdentityManager.incrementRoot();

        // Set Invalid Root History Expiry
        starkStateBridge.setRootHistoryExpiry{value: DEFAULT_GAS}(0);
        runRootPropogation();

        // Set Valid Root History Expiry
        starkStateBridge.setRootHistoryExpiry{value: DEFAULT_GAS}(10000000);
        runRootPropogation();

        // Set Valid Root History Expiry But Expired
        starkStateBridge.setRootHistoryExpiry{value: DEFAULT_GAS}(5);
        runRootPropogation();

        // Set Valid Root History Expiry, Expired But Valid (latest root always valid)
        starkStateBridge.setRootHistoryExpiry{value: DEFAULT_GAS}(5);
        runRootPropogation();
    }

    function runTransferOwner() public {
        // Invalid Owner
        //starkStateBridge.transferOwnership(address(0));

        // Valid Owner - bricks local bridge
        starkStateBridge.transferOwnership(address(1000));
    }
}
        
        
        
    