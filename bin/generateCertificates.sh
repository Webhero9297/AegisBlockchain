#! /bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cryptogen generate --config=$DIR/../config/crypto-config.yaml --output=$DIR/../crypto-config