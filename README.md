# AEGIS Blockchain Network

A blockchain network using [Hyperledger Fabric v1.0](https://www.hyperledger.org/projects/fabric) and [Hyperledger Composer](https://hyperledger.github.io/composer/).  The network consists of an Orderer, a CA authority, a peer and a CouchDB database for queries.  Additional organizations, peers and orderers will be added in a future version, along with the ability to deploy this to a Docker Swarm or Kubernetes infrastructure.

The following list of steps is required to download, configure, initialize, start and test the blockchain network. After all the steps are completed, you can start the `composer-rest-server` to interact with the network.

## Pre-requisites

To run Hyperledger Composer and Hyperledger Fabric, we recommend you have at least 4Gb of memory. The following are prerequisites for installing the required development tools:

- Operating Systems: Ubuntu Linux 16.04 LTS (64-bit). Other distributions will probably work as well, but weren't tested
- Docker Engine: Version 17.03 or higher
- Docker-Compose: Version 1.8 or higher
- Node: 8.9 or higher (version 9 is not supported)
- npm: v5.x
- git: 2.9.x or higher
- Python: 2.7.x

## 1. Download Network Files

Clone this repository along with the business network submodule:

    git clone --recurse-submodules git://github.com/aegisbigdata/aegis-blockchain.git

## 2. Install Hyperledger Fabric and Hyperledger Composer

Create a directory and download Hyperledger Fabric (docker images and command-line tools) in it:

    mkdir fabric && cd fabric
    curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/v1.0.6/scripts/bootstrap.sh | bash -s 1.0.6

Change `PATH` variable to include the `fabric/bin` directory:

    export PATH=$PATH:[path-to-fabric/bin-directory]

Install Hyperledger Composer using `npm` (using `yarn` won't work):

    npm install -g composer-cli@0.16.3 composer-rest-server@0.16.3

## 3. Create Crypto Materials

We need to create MSP for all participants in our network.  This is done by running:

    cd aegis-blockchain/bin
    ./generateCertificates.sh

*Note: All commands from now on, should be executed from within `aegis-blockchain/bin` directory, where `aegis-blockchain`  the directory you cloned this repository into.*

The configuration file for the participants can be found in  `config/crypto-config.yaml`

## 4. Initialize Fabric

We run

    ./initFabric.sh

to generate the genesis block and a transaction creating a consortium channel (both stored in the `artifact/` directory).  To change the configuration of genesis and/or consortium channel, edit `config/configtx.yaml`.

## 5. Starting Fabric Network

We start the orderer and then the peer:

    ./startOrderer.sh --tls
    ./startPeer bbc6.sics.se --tls

- `bbc6.sics.se` is the name of the peer we want to start (as used in steps 3 and 4),
- `--tls` can be ommited, but is highly recommended to be used
- after the first execution, data for each peer are stored in `data/` directory, and are loaded again when the peer restarts.

## 6. Initialize Peer

Initialize the peer (join the network and the consortium channel):

    ./initPeer.sh bbc6.sics.se

- Only needed to be executed once (the first time),
- `--tls` is not needed here, it detects how the peer was started, and adjusts automatically

## 7. Create the Business Network

We enter the `business-network/` directory and build the business network archive:

    composer archive create -t dir -n .

- filename should be `aegis-business-network@0.0.1.bna`,
- this step is only needed once,

We move back to `bin/` directory to initialize and install composer network files.

## 8. Initialize Hyplerledger Composer

Now that we have the Fabric Network ready, it's time to install the Composer and our chaincode to it. Running:

    ./initComposer.sh bbc6.sics.se --tls

does the following:

- creates and imports a card for the peer administrator (`PeerAdmin@aegis-network.card` saved in `cards/` directory),
- installs the runtime of Hyperledger Composer to the peer,
- loads the business network built in (7) to the peer (if the name is different than `aegis-business-network@0.0.1.bna` adjust `initComposer.sh` accordingly),
- creates and imports a card for the business network (`administrator@aegis-business-network.card` saved in `cards/` directory),
- pings the network using the card to see that everything is OK

### Notes:
1. Only needed to be executed the first time,
2. If you changed any of the configuration files in steps 3 and 4, you need to change `scripts/connection-tls.json` (or `scripts/connection.json` in case you are not using TLS) accordingly, otherwise composer won't be able to be initialized
3. If not using `--tls` option as instructed, the card will be named `admin@aegis-business-network` instead of `administrator@...`.
4. From now on, any interaction with the business network will be signed with `administrator@aegis-business-network` card (or `admin@aegis-business-network` in case of not using TLS).

## 9. Start REST Server

To start the REST server, you only need to run:

    composer-rest-server -c administrator@aegis-business-network -n required -w true -t true -e /usr/lib/node_modules/composer-rest-server/cert.pem -k /usr/lib/node_modules/composer-rest-server/key.pem


- The command starts the rest server, using the default certificate/key for use with TLS. This should only be used for development/testing purposes only.  For production, you need to generate and provide the server with proper certificates.
- Change to `composer-rest-server -c admin@aegis-business-network -n never -w true` if not using TLS
- The rest server is started using the administrator card created in step 8, thus has full access to the network. It should be firewalled to only allow requests from the AEGIS platform, otherwise data can be tampered by anyone.

## 10. Stop Peer / Stop Orderer

If we want to stop the network, we execute:

    ./stopPeer.sh bbc6.sics.se
    ./stopOrderer.sh

## 11. Cleanup

If we want to remove everything from our machine, we run:

    docker kill $(docker ps -q)
    docker rm $(docker ps -aq)
    docker rmi $(docker images dev-* -q)

to stop and remove all images and containers.  In order to remove created cards, peer data and installed cards, we execute:

```bash
rm ../cards/*
rm -rf ../data
rm -rf ~/.composer
```

## 12. Updates

Documentation on how to update the network, adding new organizations, orderers and peers and how to update the business network will be provided in a future release.
