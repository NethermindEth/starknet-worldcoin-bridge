// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "../src/starknet/StarknetMessaging.sol";
import "../src/StarkStateBridge.sol";
import "../src/test/MockWorldIDIdentityManager.sol";
/**
   Deploys the StarkStateBridge and StarknetMessaging contracts.
*/
contract LocalSetup is Script {
    function setUp() public {}

    function run() public{
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 starkWorldIDAddress = vm.envUint("STARK_WORLD_ID_ADDRESS");
        string memory json = "local_testing";

        vm.startBroadcast(deployerPrivateKey);

        address snCoreContract = address(new StarknetMessaging());
        vm.serializeString(json, "snMessaging_address", vm.toString(snCoreContract));

        address mockWorldIDIdentityManager = address(new MockWorldIDIdentityManager());

        address contractMsg = address(new StarkStateBridge(mockWorldIDIdentityManager, starkWorldIDAddress, snCoreContract));
        vm.serializeString(json, "contractMsg_address", vm.toString(contractMsg));

        vm.stopBroadcast();

        // string memory data = vm.serializeBool(json, "success", true);
        
        // string memory localLogs = "./logs/";
        // vm.createDir(localLogs, true);
        // vm.writeJson(data, string.concat(localLogs, "local_setup.json"));
    }
}
