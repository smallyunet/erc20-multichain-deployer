<div align="center">

# ERC20 Multichain Deployer

Deterministic and conventional deployment flow for a production‑ready ERC20 (with EIP‑2612 permit, custom decimals, owner mint, open burn) across multiple EVM chains using Foundry.

</div>

## ✨ Overview

This repository provides:

- `MyToken.sol`: Minimal, auditable ERC20 built on OpenZeppelin (`ERC20`, `ERC20Permit`, `Ownable`).
- Two deployment scripts:
	- `DeployERC20.s.sol` (standard CREATE)
	- `DeployERC20Create2.s.sol` (deterministic CREATE2)
- A convenience shell script `deploy.sh` to broadcast to several test networks (Base Sepolia, Ethereum Sepolia, Arbitrum, Polygon Amoy) with one command.
- Environment‑driven configuration (no in‑script edits) for repeatable CI / automation.
- Built‑in block explorer verification via `forge script --verify` when API keys are present.

Use CREATE for simplicity or CREATE2 to obtain the **same token address on every chain** (if deployer address, salt, and bytecode match).

## 📁 Key Structure

```
src/                  Core token contract
script/               Deployment scripts (CREATE & CREATE2)
deploy.sh             Multi-chain helper invocations
broadcast/            Forge broadcast & verification artifacts
lib/                  Dependencies (OpenZeppelin, forge-std)
test/                 Place tests here (currently empty for custom tests)
foundry.toml          Foundry configuration
```

## 🧱 Contract Summary (`MyToken.sol`)

Features:

- Custom `decimals()` (immutable) set at construction.
- Initial supply minted to `owner` (if non-zero) and ownership transferred in constructor.
- Owner-only `mint` for future emissions.
- Permissionless `burn` for holders.
- EIP‑2612 permit (gasless approvals) via `ERC20Permit`.

If you need to disable minting, remove the public `mint` function and only use constructor mint. For a capped supply, integrate `ERC20Capped` and enforce caps in `_update` / `_mint`.

## ⚙️ Environment Variables

Deployment scripts read all parameters from environment variables (e.g. `.env`).

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `TOKEN_NAME` | string | Yes | ERC20 name |
| `TOKEN_SYMBOL` | string | Yes | ERC20 symbol |
| `TOKEN_DECIMALS` | uint | Yes | Custom decimals (e.g. 18) |
| `INITIAL_SUPPLY` | uint | Yes | Whole tokens before scaling (e.g. 1_000_000) |
| `OWNER` | address | Yes | Receives initial supply & has mint authority |
| `PRIVATE_KEY` | uint hex (no 0x) | Yes | Deployer private key used by Forge |
| `SALT` | bytes32 | Only for CREATE2 | Deterministic salt (e.g. 0xabc...); omit for CREATE |
| `BASESCAN_API_KEY` | string | Optional | For Base Sepolia/Base mainnet verification |
| `ETHERSCAN_API_KEY` | string | Optional | For Ethereum (Sepolia / mainnet) |
| `ARBISCAN_API_KEY` | string | Optional | For Arbitrum |
| `POLYGONSCAN_API_KEY` | string | Optional | For Polygon / Amoy |

Example `.env` template:

```dotenv
TOKEN_NAME="My Token"
TOKEN_SYMBOL=MYT
TOKEN_DECIMALS=18
INITIAL_SUPPLY=1000000
OWNER=0xYourOwnerAddressHere
PRIVATE_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Deterministic deployments (CREATE2)
SALT=0x0000000000000000000000000000000000000000000000000000000000000042

# Optional explorer API keys for --verify
ETHERSCAN_API_KEY=YOUR_KEY
BASESCAN_API_KEY=YOUR_KEY
ARBISCAN_API_KEY=YOUR_KEY
POLYGONSCAN_API_KEY=YOUR_KEY
```

Scaling logic: The deployment script multiplies `INITIAL_SUPPLY * 10 ** TOKEN_DECIMALS` before minting.

## 🚀 Deployment

### 1. Install Foundry

Follow official docs if not installed:
```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Install Dependencies

```
forge install
```

### 3. Create & Populate `.env`

Use the template above and export (Forge auto-loads `.env` in same directory).

### 4. Standard CREATE Deployment

```
forge script script/DeployERC20.s.sol:DeployERC20 \
	--rpc-url <network_alias_or_url> \
	--broadcast --verify -vvvv
```

Where `<network_alias_or_url>` can be a Foundry profile (e.g. `sepolia`, `base-sepolia`) defined in `foundry.toml` or a full HTTPS RPC endpoint.

### 5. Deterministic CREATE2 Deployment

Ensure `SALT` is set and consistent across chains. The script prints the predicted address before broadcasting.

```
forge script script/DeployERC20Create2.s.sol:DeployERC20Create2 \
	--rpc-url <network> --broadcast --verify -vvvv
```

If you reuse the same `PRIVATE_KEY`, `SALT`, and constructor arguments on every chain, the resulting token address will match across networks (assuming identical bytecode and absent pre-existing contract at that address).

### 6. Multi-chain Helper Script

`deploy.sh` sequentially deploys (standard CREATE) to several test chains:

```bash
# Base Sepolia
forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url base-sepolia --broadcast --verify -vvvv
# Ethereum Sepolia
forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url sepolia --broadcast --verify -vvvv
# Arbitrum
forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url arbitrum --broadcast --verify -vvvv
# Polygon Amoy
forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url amoy --broadcast --verify -vvvv
```

Mark it executable and run:

```
chmod +x deploy.sh
./deploy.sh
```

You can adapt it to call the CREATE2 script for deterministic addresses.

### 7. Verification

With API keys exported, `--verify` triggers automatic source verification. Artifacts & metadata are stored under `broadcast/` per chain. If verification fails, re-run with `-vvvv` and ensure the correct API key variable is set. For manual retries you can use:

```
forge verify-contract <address> <contract_path>:MyToken <api_key> --compiler-version <solc_version>
```

## 🔍 Address Prediction (CREATE2)

The script internally computes:

```
predicted = keccak256(0xff ++ deployer ++ salt ++ keccak256(init_code))[12:]
```

It logs the predicted address before broadcasting and asserts the deployed address matches. This guarantees determinism if parameters are consistent.

## 🧪 Testing

Add custom tests under `test/` (Forge finds `*.t.sol`). Example skeleton:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "src/MyToken.sol";

contract MyTokenTest is Test {
		function testInitialSupply() public {
				MyToken t = new MyToken("My Token", "MYT", 18, address(this), 1e24);
				assertEq(t.totalSupply(), 1e24);
		}
}
```

Run:
```
forge test -vvv
```

Gas snapshot:
```
forge snapshot
```

## 🛡️ Security Notes

- Keep `PRIVATE_KEY` secure—prefer ephemeral deployer wallets or hardware signers (via RPC / bundlers) in production.
- Remove or restrict `mint` if unneeded to reduce trust assumptions.
- Consider adding a timelock or multi-sig as the `OWNER` for production deployments.
- For deterministic addresses, validate no contract already exists at the predicted address on each chain before deploying.

## 🔄 Future Improvements (Ideas)

- Optional supply cap module.
- Role-based access control (replace `Ownable` with `AccessControl`).
- Emission schedule / vesting scripts.
- CI pipeline auto-deploy & verify on merges.
- Automatic artifact publishing (addresses JSON per chain).

## 📝 License

SPDX: MIT. See `LICENSE` in dependency repos (OpenZeppelin / forge-std) for their respective licensing.

## 📚 Appendix: Foundry Quick Reference

```bash
forge build       # Compile
forge test        # Run tests
forge fmt         # Format
forge snapshot    # Gas usage snapshot
anvil             # Local dev node
cast <subcommand> # Query chain / encode data
```

Official docs: https://book.getfoundry.sh/

---

Feel free to open issues or PRs to extend functionality. Happy deploying! 🚀
