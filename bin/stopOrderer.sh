#!/bin/bash

# Exit on first error
set -e

#Detect architecture
ARCH=`uname -m`
VERSION=1.0.6


# Grab the current directorydirectory.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Shut down the Docker containers that might be currently running.
ARCH=$ARCH VERSION=$VERSION docker-compose -f "${DIR}"/../scripts/docker-compose-orderer.yaml -p "orderer" stop
