// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;
import {IWorldIDIdentityManager} from "../interfaces/IWorldIDIdentityManager.sol";

contract MockWorldIDIdentityManager is IWorldIDIdentityManager {

    function latestRoot() external view returns (uint256) {
        return 1968748234375502166459612762091612343164997079566057854091148120072677282484;
    }
}