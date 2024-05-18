// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;
import {IWorldIDIdentityManager} from "../interfaces/IWorldIDIdentityManager.sol";

contract MockWorldIDIdentityManager is IWorldIDIdentityManager {
    uint256 root = 1968748234375502166459612762091612343164997079566057854091148120072677282484;
    function incrementRoot() external {
        root += 1; 
    }

    function latestRoot() external view returns (uint256) {
        return root;
    }
}