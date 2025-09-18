// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * CREATE2 deployment to aim for the same address on multiple chains.
 * Important: With CREATE2 the resulting address depends on:
 *   - deployer address (must be the SAME across chains)
 *   - salt (must be the SAME)
 *   - init code (must be the SAME)
 *
 * Env:
 *   TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, INITIAL_SUPPLY, OWNER, PRIVATE_KEY
 *   SALT (bytes32 hex, e.g. 0x1234... or vm.envBytes32("SALT"))
 *
 * Usage:
 *   forge script script/DeployERC20Create2.s.sol:DeployERC20Create2 \
 *     --rpc-url base-sepolia --broadcast --verify -vvvv
 */

import "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployERC20Create2 is Script {
    function run() external {
        string memory name_ = vm.envString("TOKEN_NAME");
        string memory symbol_ = vm.envString("TOKEN_SYMBOL");
        uint256 decimalsU = vm.envUint("TOKEN_DECIMALS");
        require(decimalsU <= type(uint8).max, "TOKEN_DECIMALS too large");
        uint8 decimals_ = uint8(decimalsU);

        uint256 initialSupplyWhole = vm.envUint("INITIAL_SUPPLY");
        address owner_ = vm.envAddress("OWNER");
        bytes32 salt = vm.envBytes32("SALT");

        uint256 initialSupply = initialSupplyWhole * (10 ** decimals_);

        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(pk);

        // Compute predicted address before broadcast
        bytes memory initCode = abi.encodePacked(
            type(MyToken).creationCode,
            abi.encode(name_, symbol_, decimals_, owner_, initialSupply)
        );
        address predicted = vm.computeCreate2Address(
            salt,
            keccak256(initCode),
            deployer
        );

        console2.log("Predicted address (CREATE2): %s", predicted);

        vm.startBroadcast(pk);
        MyToken token = new MyToken{salt: salt}(
            name_, symbol_, decimals_, owner_, initialSupply
        );
        vm.stopBroadcast();

        require(address(token) == predicted, "Unexpected address!");
        console2.log("Deployed at: %s", address(token));
    }
}
