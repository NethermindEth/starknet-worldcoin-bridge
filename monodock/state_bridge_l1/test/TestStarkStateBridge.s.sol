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

    function run() public{
        vm.startBroadcast(deployerPrivateKey);

        RootExpiry(); 

        vm.stopBroadcast();
    }

    function runRootPropogation() public {
        starkStateBridge.propagateRoot{value: 1000000}();
        mockWorldIDIdentityManager.incrementRoot(); // mock function to simulate new root
    }

    function RootExpiry() public {
        // Setup
        runRootPropogation();
        runRootPropogation();
        starkStateBridge.propagateRoot{value: 1000000}(); // Error CANNOT_OVERWRITE_ROOT
        


    }
}
        
        
        
        //assert!(old_root_call.is_ok()); 
        //let new_root_call = world_id.require_valid_root(new_root);
        //assert!(new_root_call.is_ok()); 

        // Root is Expired
        //start_warp(CheatTarget::One(contract_address), expiry + initial_block + 1); // set block timestamp = 100
        //let old_root_call = StarkWorldID::require_valid_root(old_root);
        //assert!(old_root_call.is_err()); 

        // Root is Valid (latest root is always valid)
        //let new_root_call = StarkWorldID::require_valid_root(new_root);
        //assert!(new_root_call.is_ok()); 
