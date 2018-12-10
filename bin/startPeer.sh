#!/bin/bash

# Exit on first error
set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 PEER" >&2
  exit 1
fi

#Detect architecture
ARCH=`uname -m`
VERSION=1.0.6

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PEER=$1
CA_KEY="$( ls "${DIR}"/../crypto-config/peerOrganizations/"${PEER}"/ca | grep _sk )"

if [ "$2" == "--tls" ]; then
  echo 'Starting peer using TLS...'
  ARCH=$ARCH VERSION=$VERSION PEER=$PEER CA_KEY=$CA_KEY docker-compose -f "${DIR}"/../scripts/docker-compose-peer-tls.yaml -p "peer" down
  ARCH=$ARCH VERSION=$VERSION PEER=$PEER CA_KEY=$CA_KEY docker-compose -f "${DIR}"/../scripts/docker-compose-peer-tls.yaml -p "peer" up -d
else
  ARCH=$ARCH VERSION=$VERSION PEER=$PEER CA_KEY=$CA_KEY docker-compose -f "${DIR}"/../scripts/docker-compose-peer.yaml -p "peer" down
  ARCH=$ARCH VERSION=$VERSION PEER=$PEER CA_KEY=$CA_KEY docker-compose -f "${DIR}"/../scripts/docker-compose-peer.yaml -p "peer" up -d
fi
