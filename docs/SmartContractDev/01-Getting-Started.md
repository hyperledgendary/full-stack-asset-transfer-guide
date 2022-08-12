# Getting Started with a Smart Contract

[PREVIOUS - Introduction](./00-Introduction.md) <==>  [NEXT Create a Blank Contract](./02-Creating-Blank-Contract.md)

---

```
git clone https://github.com/hyperledgendary/full-stack-asset-transfer-guide.git workshop
cd workshop
export WORKSHOP=$(pwd)
```

First please check you've got the [required tools](../../SETUP.md) needed for the dev part of this workshop (docker, just, weft, nodejs, and Fabric peer binary). To double check run the `check.sh` script

```
${WORKSHOP}/check.sh
```

Let's dive straight into creating some code to manage an 'asset'; best to have two windows open, one for running the 'FabricNetwork' and one for 'ChaincodeDev'. You may wish to open a third to watch the logs of the running Fabric Network.

## Start the Fabric Infrastructure

We're using MicroFab for the Fabric infrastructure as it's a single container that is fast to start.
The MicroFab container includes an ordering service node and a peer process that is pre-configured to create a channel and start external chaincodes.
It also includes credentials for an `org1` organization, which will be used to run the peer. We'll use an `org1` admin user when interacting with the environment.

We'll use `just` recipes to execute multiple commands. `just` recipes are similar to `make` but simpler to understand. You can open each justfile to see which commands are run with each recipe.

Start the MicroFab container by running the `just` recipe:

```bash
just -f dev.justfile microfab
```

This will start the docker container, and also write out some configuration/data files. 
```bash
ls -1 _cfg/uf

_cfg
_gateways
_wallets
org1admin.env
org2admin.env
```

A file `org1admin.env` is written out that contains the environment variables needed to run applications _as the org1 admin identity_. A second organization is created, with a `org2admin.env` - this is for later exercises and is not needed at the moment.

Let's take a look at the environment variables and source the file to set the environment variables:

```bash
source _cfg/uf/org1admin.env
cat _cfg/uf/org1admin.env

# sample contents
export CORE_PEER_LOCALMSPID=org1MSP
export CORE_PEER_MSPCONFIGPATH=/workshop/full-stack-asset-transfer-guide/_cfg/uf/_msp/org1/org1admin/msp
export CORE_PEER_ADDRESS=org1peer-api.127-0-0-1.nip.io:8080
export FABRIC_CFG_PATH=/workshop/full-stack-asset-transfer-guide/config
export CORE_PEER_CLIENT_CONNTIMEOUT=15s
export CORE_PEER_DELIVERYTIMEOUT_CONNTIMEOUT=15s
export PATH="..../
```

Next let's look at the three directories that are created `_msp`, `_gateways`, `_wallets`
Firstly the `_msp` directory contains the file system structure for the Fabric Peer commands. You casee the refernced in the `CORE_PEER_MSGCONFIGPATH` environment variable.

Secondly the `_gatways` directory contains two JSON files, one per ogranizxation. This file contains details of the Peer's endpoint url to connect clients to. Older Fabric Client SDks would need all the information in this file, but the new "Gateway SDKs" remove the need for all the detail. The just need the peer's endpoint and tls configuration. See this [example code](../../applications/ping-chaincode/src/fabric-connection-profile.ts) on how to parse this file easily for the gateway sdk.

Third is the `_wallets` directory - there are three subdirectories for the Orderering Organization and Organizations 1 and 2. These contain details of identities:
```
_wallets
├── Orderer
│   └── ordereradmin.id
├── org1
│   ├── org1admin.id
│   └── org1caadmin.id
└── org2
    ├── org2admin.id
    └── org2caadmin.id
```

There are identities here with admin permissions for the Certificate Authorities (used to create more identities) and id to use with the Peers. 
Note the Certificate Authority created the admin ids, when Microfab started.

Pick one if the id files and look at the contents (it's json format)
```
cat _cfg/_wallets/org1/org1admin.id | jq
{
  "credentials": {
    "certificate": "-----BEGIN CERTIFICATE-----\n  xxxx \n-----END CERTIFICATE-----\n",
    "privateKey": "-----BEGIN PRIVATE KEY-----\n  xxxx  \n-----END PRIVATE KEY-----\n"
  },
  "mspId": "org1MSP",
  "type": "X.509",
  "version": 1
}

```
This information then can be used by the client applications. See [this example code](../../applications/ping-chaincode/src/jsonid-adapter.ts) for how you can directly parse this file to use with the gateway.


At this point you may wish to run `docker logs -f microfab` in a separate window to watch the activity - you don't need to setup anything specific here.

## Package and deploy chaincode to Fabric

We are going to use the Chaincode-As-A-Service (CCAAS) pattern for chaincode.
With the CCAAS pattern, the Fabric peer does not launch a deployed chaincode.
Instead, we will run chaincode as an external process so that we can easily start, stop, update, and debug the chaincode locally.
But we still need to tell the peer where the chaincode is running. We do this by deploying a chaincode package that only includes the name of the chaincode and chaincode address, rather than the actual chaincode source code.

### Package and deploy chaincode using `just` recipe.

```bash
just -f ${WORKSHOP}/dev.justfile debugcc
```

You will see the chaincode id and deployment steps returned; 

### Details of this packaging and deployment

These steps are best automated as you've just run as part of the build script. It's worth getting an idea of what is involved by running the steps manually. If you want to keep going and come back please do [skip ahead](#run-the-chaincode-locally)

Fabric chaincode packages are a `tgz` format archive that contain two files:

- `metadata.json` - the chaincode label and type
- `code.tar.gz` - source artifacts for the chaincode

Create the `metadata.json` first, this tells the Peer the type of chaincode and a label to use to refer to this later

```bash
cat << METADATAJSON-EOF > metadata.json
{
    "type": "ccaas",
    "label": "asset-tx-ts
}
METADATAJSON-EOF
```

Create the `code.tar.gz` - for the Chaincode-as-a-service, this file will contain a single JSON file `connection.json`. Traditional Fabric packaging would include all the source code of the chaincode here. In this case, we need the JSON file to contain the URL the peer will find the chaincode at and a timeout. Note this is a special hostname so the peer inside the docker container can locate the chaincode running on the host system

```
cat << CONNECTIONJSON-EOF > connection.json
{
  "address":"host.docker.internal:9999",
  "dial_timeout":"15s"
}
CONNECTIONJSON-EOF
```

We can now build the actual package.  Create a code.tar.gz archive containing the image.json file.

```bash
tar -czf code.tar.gz connection.json
```

Create the final chaincode package archive.

```bash
tar -czf go-contract.tgz metadata.json code.tar.gz
```

We're going to use the peer CLI commands to install and deploy the chaincode. Chaincode is 'deployed' by indicating agreement to it and then committing it to a channel:

```
source _cfg/uf/org1admin.env

peer lifecycle chaincode install asset-tx-ts.tgz
```

The ChaincodeID that is returned from this install command needs to be save, typically this is best as an environment variable
```bash
export CHAINCODE_ID=asset-tx-ts:133f3cdf089ae8e20fdda3e0a98cde3eb15ddbcf319bc83cb919ee28763d6e3e

peer lifecycle chaincode approveformyorg --channelID mychannel --name asset-tx -v 0 --package-id $CHAINCODE_ID --sequence 1 --connTimeout 15s
peer lifecycle chaincode commit --channelID mychannel --name asset-tx -v 0 --sequence 1 --connTimeout 15s

```

## Run the chaincode locally

We'll use the example typescript contract already written in `$WORKSHOP/contracts/asset-tx-typescript`. Feel free to take a look at the contract code in `contracts/asset-tx-typescript/src/assetTransfer`.

As with any typescript module we need to run `npm install` to manage the dependencies and then build (compile) the typescript to javascript.

Use another terminal window for the chaincode:

```
cd contracts/asset-tx-typescript

npm install

npm run build
```

On it's own a smart contract can't do a lot, however an easy way to test the contract has been built ok, is to generate the 'Contract Metatadata'. This is a language agnostic definition of the contracts, and the datatypes the contract returns. It borrows from the OpenAPI used for defining REST APIs.  It is also very useful to share to teams writing client applications so they know the data structures and transaction functions they can call.
As it's a JSON document, it's amenable to process to create other resources.

The metadata-generate command has been put into the `package.json`:

```
npm run metadata
```

Review the `metadata.json` and see the summary of the contract information, the transaction functions, and datatypes. This information can also be captured at runtime and is a good way of testing deployment.


## Iterative Development and Test

**All the steps up until here are one time only. You can now iterate over the development of your contract**

From your chaincode terminal window lets start the Smart Contract node module. Remember that the `CHAINCODE_ID` and the `CHAINCODE_SERVER_ADDRESS` are the only pieces of information needed.

Note: Use your specific CHAINCODE_ID from earlier; the `CHAINCODE_SERVER_ADDRESS` is different - this is because in this case it is telling the chaincode where to listen to for incoming connections from the Peer. Therefore is needs to find to `0.0.0.0`  

```
export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999
export CHAINCODE_ID=asset-tx-ts:133f3cdf089ae8e20fdda3e0a98cde3eb15ddbcf319bc83cb919ee28763d6e3e

# or if you ran the short cut above...
# source ${WORKSHOP}/_cfg/uf/org1admin.env

npm run start:server-debug
```

### Run some transactions

Choose a terminal window to run the transactions from; initially we'll use the `peer` CLI to run the commands.
Make sure that the peer binary and the config directory are set (run the `${WORKKOP}/check.sh script to double check).

Set up the environment context for acting as the Org 1 Administrator.

```
source ${WORKSHOP}/_cfg/uf/org1admin.env
```

Use the peer CLI to issue basic query commands against the contract. For example check the metadata for the contract (if you have jq, it's easier to read if you pipe the results into jq). Use one of these commands:

```
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}'
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}' | jq
```

Let's create an asset with ID=001:

```
peer chaincode invoke -C mychannel -n asset-tx -c '{"Args":["CreateAsset","{\"ID\":\"001\", \"Color\":\"Red\",\"Size\":52,\"Owner\":\"Fred\",\"AppraisedValue\":234234}"]}' --connTimeout 15s
```

And read back that asset:

```
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["ReadAsset","001"]}'
```

You'll see the asset returned:

```
{"AppraisedValue":234234,"Color":"Red","ID":"001","Owner":"{\"org\":\"org1MSP\",\"user\":\"Fred\"}","Size":52}
```

### Making a change and re-running the code

If we invoke a query command on a asset that does not exist, for example 002, we'll get back an error:

```
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["ReadAsset","002"]}'
```

returns error:

```
Error: endorsement failure during query. response: status:500 message:"Sorry, asset 002 has not been created"
```

Let's say we want to change that error message to something else.

- Stop the running chaincode (CTRL-C!)
- Load the `src/assetTransfer.ts` file into an editor of your choice
- Around line 51, find the error string and make a modification. remembering to save the change
- Rebuild this as it's typscreipt with "npm run build"

You can now restart the contract as before

```
npm run start:server-debug
```


And run the same query, and see the updated error message:

```
peer chaincode query -C mychannel -n asset-tx -c '{"Args":["ReadAsset","002"]}'
```

## Debugging

As the chaincode was started with the Node.js debug setting, you can connect a node.js debugger. For example VSCode has a good
typescript/node.js debugging in built. 

If you select the debug tab, and open the debug configurations, add a "Attach to a node.js process" configuration. VSCode will prompt you 
with the template. The default port should be sufficient here.  You can then start the 'attached to process' debug, and pick the process to debug into.

Remember to set a breakpoint at the start of the transaction function you want to debug.

Watch out for:
    - vscode uses node, so take care in selecting the right process
    - remember the client/fabric transaction timeout, whilst you've the chaicode stopped in the debugger, the timeout is still 'ticking'


Next look at the [Test and Debuging Contracts](./03-Test-And-Debug.md) for more details and information on other langauges
