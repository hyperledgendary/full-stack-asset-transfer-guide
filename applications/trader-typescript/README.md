# Trader sample client application

This is a simple client application for the [asset-transfer](../../contracts/asset-tx-typescript/) smart contract, built using the [Fabric Gateway client API](https://hyperledger.github.io/fabric-gateway/) for Fabric v2.4+.

## Prerequisites

The client application requires Node.js 16 or later.

## Set up

The following steps prepare the client application for execution:

1. Ensure the [asset-transfer](../../contracts/asset-tx-typescript/) smart contract is deployed to a running Fabric network.
1. Run `npm install` to download dependencies and compile the application code.

> **Note:** After making any code changes to the application, be sure to recompile the application code. This can be done by explicitly running `npm install` again, or you can leave `npm run build:watch` running in a terminal window to automatically rebuild the application on any code change.

## Run

The client application uses environment variables to supply configuration options. You should set the following environment variables when running the application:

- `MSP_ID` - member service provider ID for the user's organization.
- `CERTIFICATE` - PEM file containing the user's X.509 certificate.
- `PRIVATE_KEY` - PEM file containing the user's private key.
- `ENDPOINT` - endpoint address for the Gateway service to which the client will connect in the form **hostname:port**. Depending on your environment, this can be the address of a specific peer within the user's organization, or an ingress endpoint that dispatches to aany available peer in the user's organization.
- `TLS_CERT` - PEM file containing the CA certificate used to authenticate the TLS connection to the Gateway peer.
- `HOST_ALIAS` - the name of the Gateway peer as it appears in its TLS certificate. *Only required if the endpoint address used by the client does not match the address in the Gateway peer's TLS certificate.*

The sample application is run as a command-line application, and is lauched using `npm start <command> [<arg> ...]`. The following commands are available:

- `npm start create <assetId> <ownerName> <color>` to create a new asset.
- `npm start delete <assetId>` to delete an existing asset.
- `npm start getAllAssets` to list all assets.
- `npm start listen` to listen for chaincode events emitted by transaction functions. Interrupt the listener using Control-C.
- `npm start read <assetId>` to view an existing asset.
- `npm start transact` to create some random assets and perform some random operations on those assets.
- `npm start transfer <assetId> <ownerName> <ownerMspId>` to transfer an asset to a new owner within an organization MSP ID.
