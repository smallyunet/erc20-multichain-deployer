// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * Simple, production-friendly ERC20 with:
 * - Custom name/symbol/decimals
 * - Initial mint to an owner
 * - Owner-only mint, open burn
 * - EIP-2612 permit (gasless approvals)
 *
 * Notes:
 * - If you don't want mintability, remove `mint` and call `_mint` only in constructor.
 * - If you need a cap, add ERC20Capped and enforce it in _update/_mint.
 */

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, ERC20Permit, Ownable {
    uint8 private immutable _customDecimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address owner_,
        uint256 initialSupply   // raw units (already scaled by decimals)
    )
        ERC20(name_, symbol_)
        ERC20Permit(name_)
        Ownable(owner_)
    {
        _customDecimals = decimals_;
        if (initialSupply > 0) {
            _mint(owner_, initialSupply);
        }
    }

    /// @notice Override decimals to a custom value.
    function decimals() public view override returns (uint8) {
        return _customDecimals;
    }

    /// @notice Owner-only minting hook.
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice Any holder can burn their tokens.
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
