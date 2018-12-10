#! /bin/bash
set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 PEER" >&2
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PEER=$1
SECRET="$( ls "$DIR/../crypto-config/peerOrganizations/$PEER/users/Admin@$PEER/msp/keystore" | grep _sk )"

# Creating a business network card for the Hyperledger Fabric administrator
if [ "$2" == "--tls" ]; then
  CONNECTION_JSON="connection-tls.json"
else
  CONNECTION_JSON="connection.json"
fi

composer card create -f $DIR/../cards/PeerAdmin@aegis-network.card -p $DIR/../scripts/$CONNECTION_JSON -u PeerAdmin -c $DIR/../crypto-config/peerOrganizations/$PEER/users/Admin@$PEER/msp/signcerts/Admin@$PEER-cert.pem -k $DIR/../crypto-config/peerOrganizations/$PEER/users/Admin@$PEER/msp/keystore/$SECRET  -r PeerAdmin -r ChannelAdmin

# Importing the business network card for the Hyperledger Fabric administrator
composer card import -f $DIR/../cards/PeerAdmin@aegis-network.card

# Installing the Hyperledger Composer runtime onto the Hyperledger Fabric peer nodes
composer runtime install -c PeerAdmin@aegis-network -n aegis-business-network

if [ "$2" == "--tls" ]; then
    # Retrieving business network administrator certificates
    composer identity request -c PeerAdmin@aegis-network -u admin -s adminpw -d administrator

    # Starting the blockchain business network
    composer network start -c PeerAdmin@aegis-network -a $DIR/../business-network/aegis-business-network@0.0.1.bna -A administrator -C administrator/admin-pub.pem

    # Creating a business network card to access the business network
    composer card create -p $DIR/../scripts/$CONNECTION_JSON -u administrator -n aegis-business-network -c administrator/admin-pub.pem -k administrator/admin-priv.pem -f $DIR/../cards/administrator@aegis-business-network.card

    # Importing the business network card for the business network administrator
    composer card import -f $DIR/../cards/administrator@aegis-business-network.card

    # Testing the connection to the blockchain business network
    composer network ping -c administrator@aegis-business-network
else
    # Starting the blockchain business network
    composer network start -c PeerAdmin@aegis-network -a $DIR/../business-network/aegis-business-network@0.0.1.bna -A admin -S adminpw -f $DIR/../cards/admin@aegis-business-network.card

    # Importing the business network card for the business network administrator
    composer card import -f $DIR/../cards/admin@aegis-business-network.card

    # Testing the connection to the blockchain business network
    composer network ping -c admin@aegis-business-network
fi
