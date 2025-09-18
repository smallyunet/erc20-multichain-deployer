// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * Standard CREATE deployment script.
 * Reads parameters from environment variables:
 *   TOKEN_NAME (string)
 *   TOKEN_SYMBOL (string)
 *   TOKEN_DECIMALS (uint) - e.g. 18
 *   INITIAL_SUPPLY (uint) - whole tokens, NOT scaled (e.g. 1_000_000)
 *   OWNER (address)       - who receives ownership & initial supply
 *   PRIVATE_KEY (hex)     - deployer key
 *
 * Scaling: initialSupplyRaw = INITIAL_SUPPLY * (10 ** TOKEN_DECIMALS)
 *
 * Usage:
 *   forge script script/DeployERC20.s.sol:DeployERC20 \
 *     --rpc-url base-sepolia --broadcast --verify -vvvv
 */

import "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployERC20 is Script {
    function run() external {
        string memory name_ = vm.envString("TOKEN_NAME");
        string memory symbol_ = vm.envString("TOKEN_SYMBOL");
        uint256 decimalsU = vm.envUint("TOKEN_DECIMALS");
        require(decimalsU <= type(uint8).max, "TOKEN_DECIMALS too large");
        uint8 decimals_ = uint8(decimalsU);

        uint256 initialSupplyWhole = vm.envUint("INITIAL_SUPPLY");
        address owner_ = vm.envAddress("OWNER");

        // scale initial supply to raw units
        uint256 initialSupply = initialSupplyWhole * (10 ** decimals_);

        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        MyToken token = new MyToken(
            name_,
            symbol_,
            decimals_,
            owner_,
            initialSupply
        );

        vm.stopBroadcast();

        console2.log("MyToken deployed:");
        console2.log("  address: %s", address(token));
        console2.log("  name:    %s", name_);
        console2.log("  symbol:  %s", symbol_);
        console2.log("  owner:   %s", owner_);
        console2.log("  decimals:%s", decimals_);
    }
}
