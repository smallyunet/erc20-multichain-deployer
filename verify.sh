SUPPLY_RAW=$(cast --to-wei "$INITIAL_SUPPLY" "$TOKEN_DECIMALS")

ARGS=$(cast abi-encode \
  "constructor(string,string,uint8,address,uint256)" \
  "$TOKEN_NAME" "$TOKEN_SYMBOL" "$TOKEN_DECIMALS" "$OWNER" "$SUPPLY_RAW")

forge verify-contract \
  --watch \
  --chain 80002 \
  0x123c6CD93AC01A892277BB36424467ca6e53ca23 \
  src/MyToken.sol:MyToken \
  --verifier etherscan \
  --etherscan-api-key "$ETHERSCAN_API_KEY" \
  --constructor-args $ARGS \
  --compiler-version v0.8.24 \
  --num-of-optimizations 200 \
  --evm-version cancun