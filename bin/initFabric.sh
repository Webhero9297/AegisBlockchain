#! /bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export FABRIC_CFG_PATH=$DIR/../config

configtxgen -profile AEGISOrdererGenesis -outputBlock $DIR/../artifacts/aegis-genesis.block
configtxgen -profile ConsortiumChannel -outputCreateChannelTx $DIR/../artifacts/consortium-channel.tx -channelID consortium