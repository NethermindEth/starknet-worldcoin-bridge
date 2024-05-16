// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../src/StarkStateBridge.sol";

contract StarkStateBridgeScript is Script {
	uint256 mainnetFork;
	address _worldIDIden = vm.envAddress("WORLD_ID_IDENTITY_MANAGER");
	uint256 _starkWorldID = vm.envUint("STARK_WORLD_ID_ADDRESS");
	address _snMessaging = vm.envAddress("SN_MESSAGING_ADDRESS");
	uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
	string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
	// testing
	uint256 _l2ContractAddress = vm.envUint("L2_CONTRACT_ADDRESS");
    uint256 _l2Selector = vm.envUint("L2_SELECTOR_VALUE");
	function run() public {
		vm.startBroadcast(deployerPrivateKey);
		
		//StarkStateBridge starkStateBridge = new StarkStateBridge(_worldIDIden, _starkWorldID, _snMessaging);

		uint256[] memory payload = new uint256[](1);
        payload[0] = 123;

		// StarkStateBridge(0x8Aed6FE10dF3d6d981B101496C9c7245AE65cAEc).sendMessage{value: 30000}(
        //     _l2ContractAddress,
        //     _l2Selector,
        //     payload);
	
		vm.stopBroadcast();
	}
}