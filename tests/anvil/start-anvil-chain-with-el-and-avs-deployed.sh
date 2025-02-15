#!/bin/bash

RPC_URL=http://localhost:8545
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# cd to the directory of this script so that this can be run from anywhere
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

# start an anvil instance in the background that has eigenlayer contracts deployed
# we start anvil in the background so that we can run the below script
anvil --load-state avs-and-eigenlayer-deployed-anvil-state.json &
ANVIL_PID=$!

cd ../../contracts
# we need to restart the anvil chain at the correct block, otherwise the indexRegistry has a quorumUpdate at the block number
# at which it was deployed (aka quorum was created/updated), but when we start anvil by loading state file it starts at block number 0
# so calling getOperatorListAtBlockNumber reverts because it thinks there are no quorums registered at block 0
# advancing chain manually like this is a current hack until https://github.com/foundry-rs/foundry/issues/6679 is merged
# also not that it doesn't really advance by the correct number of blocks.. not sure why, so we just forward by a bunch of blocks that should be enough
# install foundry dependencies
forge install

forge script script/utils/Utils.sol --sig "advanceChainByNBlocks(uint256)" 100 --rpc-url $RPC_URL  --private-key $PRIVATE_KEY --broadcast
echo "current block-number:" $(cast block-number)

# Bring Anvil back to the foreground
wait $ANVIL_PID
