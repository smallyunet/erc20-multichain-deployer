SUPPLY_RAW=$(cast --to-wei "$INITIAL_SUPPLY" "$TOKEN_DECIMALS")

ARGS=$(cast abi-encode \
  "constructor(string,string,uint8,address,uint256)" \
  "$TOKEN_NAME" "$TOKEN_SYMBOL" "$TOKEN_DECIMALS" "$OWNER" "$SUPPLY_RAW")

forge verify-contract \
  --chain base-sepolia \
  --verifier-url "$BASESCAN_SEPOLIA_API" \
  --etherscan-api-key "$BASESCAN_API_KEY" \
  --compiler-version v0.8.24 \
  --num-of-optimizations 200 \
  --evm-version cancun \
  0xYourDeployedTokenAddressHere \
  src/MyToken.sol:MyToken \
  --constructor-args $ARGS \
  --watch