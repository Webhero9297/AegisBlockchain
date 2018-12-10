#!/bin/bash

# Exit on first error
set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 PEER" >&2
  exit 1
fi

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PEER=$1

# Create the channel
docker exec peer0.$PEER sh -c 'peer channel create --tls $CORE_PEER_TLS_ENABLED --cafile $TLSCA_FILE -o orderer.bbc6.sics.se:7050 -c consortium -f /etc/hyperledger/configtx/consortium-channel.tx'

# Join peer0 to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${PEER}/msp" peer0.${PEER} peer channel join -b consortium.block
