# Base Sepolia
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url base-sepolia \
  --broadcast --verify -vvvv

# Ethereum Sepolia
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url sepolia --broadcast --verify -vvvv

# Arbitrum
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url arbitrum --broadcast --verify -vvvv

# Polygon Amoy
forge script script/DeployERC20.s.sol:DeployERC20 \
  --rpc-url amoy --broadcast --verify -vvvv
