// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../src/StarkStateBridge.sol";

contract StarkStateBridgeScript is Script {
	address _worldIDIden = vm.envAddress("WORLD_ID_IDENTITY_MANAGER");
	address _starkWorldI = vm.envAddress("STARK_WORLD_ID_ADDRESS");
	address _snMessaging = vm.envAddress("SN_MESSAGING_ADDRESS");

	function run() public {
		vm.broadcast();
		StarkStateBridge starkStateBridge = new StarkStateBridge(_worldIDIden, _starkWorldI, _snMessaging);
	}
}