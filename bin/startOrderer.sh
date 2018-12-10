#!/bin/bash

# Exit on first error
set -e

#Detect architecture and version
ARCH=`uname -m`
VERSION=1.0.6

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$1" == "--tls" ]; then
  echo "Starting orderer using TLS..."
  ARCH=$ARCH VERSION=$VERSION docker-compose -f "${DIR}"/../scripts/docker-compose-orderer-tls.yaml -p "orderer" down
  ARCH=$ARCH VERSION=$VERSION docker-compose -f "${DIR}"/../scripts/docker-compose-orderer-tls.yaml -p "orderer" up -d
else
  ARCH=$ARCH VERSION=$VERSION docker-compose -f "${DIR}"/../scripts/docker-compose-orderer.yaml -p "orderer" down
  ARCH=$ARCH VERSION=$VERSION docker-compose -f "${DIR}"/../scripts/docker-compose-orderer.yaml -p "orderer" up -d
fi
