# Base Sepolia
export FOUNDRY_PROFILE=sepolia-dev
export FOUNDRY_PROFILE=sepolia-prod
export FOUNDRY_PROFILE=sepolia-weth
export FOUNDRY_PROFILE=sepolia-clp
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url base-sepolia \
  --broadcast --verify -vvvv

# Base Mainnet
export FOUNDRY_PROFILE=base-weth
export FOUNDRY_PROFILE=base-clp
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url base \
  --broadcast --verify -vvvv

# Ethereum Sepolia
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url sepolia \
  --broadcast --verify -vvvv

# Arbitrum
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url arbitrum \
  --broadcast --verify -vvvv

# Polygon Amoy
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url amoy \
  --broadcast --verify -vvvv
