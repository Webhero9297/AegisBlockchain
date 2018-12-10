#!/bin/bash

# Exit on first error
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 PEER" >&2
  exit 1
fi

#Detect architecture
ARCH=`uname -m`
VERSION=1.0.6
FABRIC_START_TIMEOUT=15

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PEER=$1
CA_KEY="$( ls "${DIR}"/../crypto-config/peerOrganizations/"${PEER}"/ca | grep _sk )"

ARCH=$ARCH VERSION=$VERSION PEER=$PEER docker-compose -f "${DIR}"/../scripts/docker-compose-peer.yaml -p "peer" stop
